import React from "react"
import PropTypes from "prop-types"
import HelloWorld from "./HelloWorld";

class UserCheck extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      error: null,
      isLoaded: false,
      user: null
    };
  }

  componentDidMount() {
    fetch("/stash/react_user")
        .then(res => res.json())
        .then(
            (result) => {
              this.setState({
                isLoaded: true,
                user: result
              });
            },
            // Note: it's important to handle errors here
            // instead of a catch() block so that we don't swallow
            // exceptions from actual bugs in components.
            (error) => {
              this.setState({
                isLoaded: true,
                error
              });
            }
        )
  }

  render() {
    const { error, isLoaded, user } = this.state;
    if (error) {
      return <div>Error: {error.message}</div>;
    } else if (!isLoaded) {
      return <div>Loading...</div>;
    } else {
      return (
          <ul>
            <li key={user.id}>
              orcid: {user.orcid}
            </li>
            <li>email: {user.email}</li>
            <li>first name: {user.first_name}</li>
            <li>last name: {user.last_name}</li>
            <li>tenant id: {user.tenant_id}</li>
            <li>role: {user.role}</li>
          </ul>
      );
    }
  }
}

export default UserCheck