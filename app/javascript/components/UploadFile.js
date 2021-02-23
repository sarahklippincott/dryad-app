import React from "react"
import PropTypes from "prop-types"
class UploadFile extends React.Component {
  render () {
    return (
      <React.Fragment>
        Resource: {this.props.resource}
      </React.Fragment>
    );
  }
}

UploadFile.propTypes = {
  resource: PropTypes.string
};
export default UploadFile
