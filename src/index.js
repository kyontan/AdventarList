import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'

class Calendar extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      path: null,
      hide_theme: false,
      hide_writer: false,
      articles: [],
      writer: null,
      calendar: null,
      type: null,
      date: null,
    }
  }

  componentDidMount() {
    this.getType();
    this.getPath(this.fetchData);
  }

  fetchData() {
    fetch(`/${this.state.path}.json`)
      .then((response) => {
        return response.json()
      }).then((json) => {
        this.setState({
          articles: json.articles,
          writer: json.writer,
          calendar: json.calendar
        });
      }).catch((error) => {
        this.setState({
          articles: [],
          writer: null,
          calendar: null
        });
      });
  }

  dateToString(date) {
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  }

  getType() {
    var path_type = location.pathname.split("/")[1]; // `example.com/{here}/...`
    var type = "normal";

    if (path_type === "calendar") {
      type = "theme";
    } else if (path_type === "writer") {
      type = "writer";
    }

    this.setState({
      type: type,
      hide_theme: type === "theme",
      hide_writer: type === "writer"
    });

    return type;
  }

  getPath(cb) {
    var path = location.pathname.slice(1);
    if (this.getType() !== "normal") {
      this.setState({ date: null, path: path }, cb)
      return path;
    }

    var date = new Date(path);
    if (isNaN(date)) {
      date = new Date();
    }

    if (date.getMonth() != 11) { // December
      date.setMonth(11)
    }

    if (25 < date.getDate()) {
      date.setDate(25);
    }

    path = this.dateToString(date);
    this.setState({ date: date, path: path }, cb)
    return path;
  }

  render() {
    return (
      <div>
        <CalendarNavigator
          path={this.state.path}
          type={this.state.type}
          date={this.state.date}
          writer={this.state.writer}
          calendar={this.state.calendar}
        />
        <CalendarList
          articles={this.state.articles}
          hideTheme={this.state.hide_theme}
          hideWriter={this.state.hide_writer} />
      </div>
    );
  }
}

class CalendarNavigator extends React.Component {
  constructor(props) {
    super(props)
  }

  dateToString(date) {
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  }

  dateWithDiff(date, diff) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() + diff);
  }

  dateToPathWithDiff(date, diff) {
    return `/${this.dateToString(this.dateWithDiff(date, diff))}`;
  }

  render() {
    var type = this.props.type;

    if (type === "normal") {
      var date = this.props.date;

      if (!date) {
        return <h2></h2>
      }

      var d = date.getDate();
      return (
        <nav>
          {d != 1 && <a href={this.dateToPathWithDiff(date, -1)}>前日の記事一覧</a> }
          <h2>{this.props.path}の記事一覧</h2>
          {d < 25 && <a href={this.dateToPathWithDiff(date, 1)}>翌日の記事一覧</a> }
          {d == 25 && "🎄Merry Xmas!🎄" }
        </nav>
      );
    }

    var title = null;

    if (type === "writer") {
      var writer = this.props.writer;
      title = writer && `${writer.name}の`;
    }

    if (type === "theme") {
      var calendar = this.props.calendar;
      title = calendar && `${calendar.title}の`;
    }

    return <h2>{title}記事一覧</h2>
  }
}

class CalendarList extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    if (!Array.isArray(this.props.articles)) {
      return (<div className="no-article">記事がありません</div>);
    }

    var articles = this.props.articles.map((article) => {
      return (
        <CalendarArticle
          key={article.id.toString()}
          article={article}
          hideTheme={this.props.hideTheme}
          hideWriter={this.props.hideWriter}>
        </CalendarArticle>
      );
    })

    return (
      <table id="articles">
        <thead>
          <tr>
            { !this.props.hideTheme && <th className="theme">Theme</th> }
            <th className="title">Article</th>
            { !this.props.hideWriter && <th className="writer">Writer</th> }
          </tr>
        </thead>
        <tbody>
          {articles}
        </tbody>
      </table>
    );
  }
}

class CalendarArticle extends React.Component {
  constructor(props) {
    super(props)
  }

  urlOfCalendar(calendar) {
    return `/calendar/${calendar.service}/${calendar.in_service_id}`;
  }

  urlOfWriter(writer) {
    return `/writer/${writer.service}/${writer.in_service_id}`;
  }

  render() {
    var article = this.props.article;
    var calendar = article.calendar;
    var writer = article.writer;

    var $theme = null, $writer = null;
    if (!this.props.hideTheme) {
      $theme = <td className="theme"><a href={this.urlOfCalendar(calendar)}>{calendar.title}</a></td>
    }

    if (!this.props.hideWriter) {
      $writer = <td className="writer"><a href={this.urlOfWriter(writer)}>{writer.name}</a></td>
    }

    return (
      <tr>
        { $theme }
        <td className="title"><a href={article.url}>{article.title || "記事名なし"}</a></td>
        { $writer }
      </tr>
    );
  }
}

ReactDOM.render(<Calendar />, document.getElementById("calendar"));
