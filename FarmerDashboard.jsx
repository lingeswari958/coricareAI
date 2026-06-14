import { Link } from "react-router-dom";

function FarmerDashboard() {
  return (
    <div>
      <h1>Farmer Dashboard</h1>

      <div>
        <h3>Leaf Scans</h3>
        <p>15</p>
      </div>

      <div>
        <h3>Diseases Detected</h3>
        <p>3</p>
      </div>

      <Link to="/scan">
        <button>
          Upload Leaf Image
        </button>
      </Link>
    </div>
  );
}

export default FarmerDashboard;
