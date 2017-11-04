<%@page import="org.muffin.muffin.servlets.SessionKeys" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="m" tagdir="/WEB-INF/tags" %>
<m:base>
    <jsp:attribute name="title">${sessionScope.get(SessionKeys.MUFF).name}  | Home</jsp:attribute>
    <jsp:attribute name="css">
        <style>
            #top-action-bar {
                position: fixed;
                z-index: 1000;
                top: 0;
                left: 0;
                width: 100vw;
                height: 60px;
                background-color: #6d4c41;
            }

            #icon {
                position: absolute;
                left: 10px;
                top: 20px;
            }

            #search-app {
                position: absolute;
                z-index: 1000;
                top: 10px;
                left: 25vw;
                width: 50vw;
                height: 40px;
                background-color: white;
                border-radius: 2px;
            }

            #search-app td {
                padding: 10px;
                font-size: large;
                cursor: pointer;
            }

            #search-app input {
                border: none !important;
                outline: none;
                box-shadow: none;
                margin: 0 !important;
                font-size: large !important;
            }

            #search-app input:focus {
                border: none !important;
                outline: none;
                box-shadow: none !important;
            }

            #left-action-bar {
                position: fixed;
                z-index: 1000;
                top: 100px;
                left: 10px;
                width: 16vw;
                height: 85vh;
                border: 1px solid black;
            }

            #right-action-bar {
                position: fixed;
                z-index: 1000;
                top: 100px;
                right: 10px;
                width: 16vw;
                height: 85vh;
                border: 1px solid black;
            }

            #feed {
                position: relative;
                z-index: 999;
                top: 100px;
                border: 1px solid black;
            }
        </style>
    </jsp:attribute>
    <jsp:body>
        <script type="text/babel">

            let isReviewValid = function (name, rating, review) {
                if (name === '') {
                    Materialize.toast('Movie name is empty!', 3000);
                    return false;
                }
                if (name.length > 50) {
                    Materialize.toast('Movie name must be less than 50 characters!', 3000);
                    return false;
                }

                if (rating === '' && review === '') {
                    Materialize.toast('Both rating and review cannot be empty!', 3000);
                    return false;
                }


                if (isNaN(Number(rating)) && rating != '') {
                    Materialize.toast('Invalid Rating!', 3000);
                    return false;
                }
                rating = Number(rating);
                if (rating < 0 || rating > 10) {
                    Materialize.toast('Invalid rating!', 3000);
                    return false;
                }
                return true;
            };


            let MuffSearchResult = React.createClass({
                render: function () {
                    return (
                            <tr>
                                <td>{this.props.name}</td>
                                <td className="pink-text">{this.props.handle}</td>
                            </tr>
                    );
                }
            });

            let SearchApp = React.createClass({
                MODE: {
                    MOVIE: 0,
                    ACTOR: 1,
                    MUFF: 2,
                },
                getInitialState: function () {
                    return {
                        mode: this.MODE.MUFF,
                        movies: [],
                        muffs: [],
                        actors: [],
                    }
                },
                onRegexInputKeyDown: function (e) {
                    let self = this;
                    switch (e.keyCode || e.which) {
                        // Enter Key
                        case 13:
                            let url;
                            switch (this.state.mode) {
                                case this.MODE.MUFF:
                                    url = '${pageContext.request.contextPath}/muff/search';
                                    break;
                                case this.MODE.ACTOR:
                                    url = '${pageContext.request.contextPath}/actor/search';
                                    break;
                                case this.MODE.MOVIE:
                                    url = '${pageContext.request.contextPath}/movie/search';
                                    break;
                                default:
                                    break;
                            }
                            $.ajax({
                                url: url,
                                type: 'GET',
                                data: {searchKey: e.target.value},
                                success: function (r) {
                                    let json = JSON.parse(r);
                                    if (json.status === -1) {
                                        Materialize.toast(json.error, 2000);
                                    }
                                    else {
                                        let data = json.data;
                                        switch (self.state.mode) {
                                            case self.MODE.MUFF:
                                                self.setState(ps => {
                                                    return {muffs: data};
                                                });
                                                break;
                                            case self.MODE.ACTOR:
                                                self.setState(ps => {
                                                    return {actors: data};
                                                });
                                                break;
                                            case self.MODE.MOVIE:
                                                self.setState(ps => {
                                                    return {movies: data};
                                                });
                                                break;
                                            default:
                                                break;
                                        }
                                        $(self.refs.results).show();
                                    }
                                },
                                error: function (data) {
                                    Materialize.toast('Server Error', 2000);
                                }
                            });
                            break;
                        // Escape key
                        case 27:
                            $(this.refs.results).hide();
                            break;
                        default:
                            break;
                    }
                },
                render: function () {
                    let results = this.state.muffs.map(muff => {
                        return <MuffSearchResult
                                key={muff.id}
                                id={muff.id}
                                name={muff.name}
                                handle={muff.handle}
                                level={muff.level}
                        />;
                    });
                    return (
                            <div>
                                <input onKeyDown={this.onRegexInputKeyDown}
                                       placeholder="Search" type="text"/>
                                <table className="white" ref="results">
                                    <tbody>
                                    {results.length === 0 ? <tr>
                                        <td className="red white-text">No matching muffs</td>
                                    </tr> : results}
                                    </tbody>
                                </table>
                            </div>
                    );
                },
                componentDidMount: function () {
                    $(this.refs.results).hide();
                },
            });

            let MuffAddMovieReview = React.createClass({
                addMovieReview: function () {
                    let self = this;
                    // validation
                    if (!isReviewValid(this.refs.movieName.value, this.refs.movieRating.value, this.refs.movieReview.value)) {
                        return;
                    }
                    // ajax call
                    console.log(this.refs.movieRating.value);

                    $.ajax({
                        url: '${pageContext.request.contextPath}/muff/addreview',
                        type: 'POST',
                        data: {
                            movieName: this.refs.movieName.value,
                            movieRating: this.refs.movieRating.value,
                            movieReview: this.refs.movieReview.value
                        },
                        success: function (r) {
                            let json = JSON.parse(r);
                            if (json.status === -1) {
                                Materialize.toast(json.error, 2000);
                            }
                            else {
                                Materialize.toast("Review Added Successfully", 2000);
                            }
                        },
                        error: function (data) {
                            Materialize.toast('Server Error', 2000);
                        }
                    });
                },
                render: function () {
                    return (
                            <div>
                                <input type="text" ref="movieName"
                                       name="movieName" placeholder="Movie Name" defaultValue=""/>
                                <input type="number" min="1" max="10"
                                       ref="movieRating" name="movieRating" placeholder="Movie Rating"
                                       defaultValue=""/>
                                <input type="text" ref="movieReview"
                                       name="movieReview" placeholder="Movie Review" defaultValue=""/>
                                <button onClick={this.addMovieReview}
                                        className="btn-floating waves-effect waves-light green">
                                    <i className="material-icons">add</i>
                                </button>
                            </div>
                    );
                }
            });

            ReactDOM.render(<MuffSearchApp/>, document.getElementById('muff-search-app'));
            ReactDOM.render(<MuffAddMovieReview/>, document.getElementById('muff-movie-review'));
        </script>
        <div class="container-fluid">
            <div id="top-action-bar">
                <div id="icon"><img src="${pageContext.request.contextPath}/static/logo.ico"
                                    alt="muffin" width="64" height="64"></div>
                <div id="search-app"></div>
            </div>
            <div id="left-action-bar"></div>
            <div id="right-action-bar"></div>
            <div class="row">
                <div class="col l8 m8 s8 offset-s2 offset-m2 offset-l2">
                    <div id="feed" style="height: 200vh;">
                        <div id="muff-movie-review"></div>

                    </div>
                </div>
            </div>
        </div>
    </jsp:body>
</m:base>