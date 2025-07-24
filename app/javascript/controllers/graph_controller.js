import { Controller } from "@hotwired/stimulus";
import * as d3 from "d3";

export default class extends Controller {
  connect() {
    let d3_matches = document.getElementById("d3_matches")?.value;

    if (d3_matches) {
      d3_matches = JSON.parse(d3_matches);

      const height = screen.width;
      const radius = 16;
      const step = 23;
      const theta = 2.399963229728653;
      const width = screen.width; 

      const data = d3_matches.map((match, i) => {
        const r = step * Math.sqrt(i + 0.5);
        const a = theta * i;
        return {
          x: width / 2 + r * Math.cos(a),
          y: height / 2 + r * Math.sin(a),
          match: match,
        };
      });

      function chart() {
        let currentTransform = [width / 2, height / 2, height];

        const svg = d3
          .create("svg")
          .attr("viewBox", [0, 0, width, height])
          .attr("width", width) // Add width attribute
          .attr("height", height); // Add height attribute

        const g = svg.append("g");

        g.selectAll("circle")
          .data(data)
          .join("circle")
          .attr("cx", (d) => d.x)
          .attr("cy", (d) => d.y)
          .attr("r", radius)
          .attr("fill", (d, i) => d3.interpolateRainbow(i / data.length))
          .append("title")
          .text((d, i) => `${d.match[0]} win`);

        g.selectAll(".tour-name")
          .data(data)
          .join("text")
          .attr("class", "tour-name")
          .attr("x", (d) => d.x)
          .attr("y", (d) => d.y - 8)
          .attr("text-anchor", "middle")
          .attr("fill", "white")
          .style("font-size", "2px")
          .text((d, i) => `${d.match[2]}`);

        g.selectAll(".win-text")
          .data(data)
          .join("text")
          .attr("class", "win-text")
          .attr("x", (d) => d.x)
          .attr("y", (d) => d.y)
          .attr("text-anchor", "middle")
          .attr("fill", "white")
          .style("font-size", "4px")
          .text((d, i) => `${d.match[0]} win`);

        g.selectAll(".lose-text")
          .data(data)
          .join("text")
          .attr("class", "lose-text")
          .attr("x", (d) => d.x)
          .attr("y", (d) => d.y + 2.5)
          .attr("text-anchor", "middle")
          .attr("fill", "black")
          .style("font-size", "2px")
          .text((d, i) => `vs ${d.match[1]}`);

        g.selectAll(".run-text")
          .data(data)
          .join("text")
          .attr("class", "run-text")
          .attr("x", (d) => d.x)
          .attr("y", (d) => d.y + 7)
          .attr("text-anchor", "middle")
          .attr("fill", "black")
          .style("font-size", "2px")
          .text((d, i) => d.match[3]);

        g.selectAll(".wicket-text")
          .data(data)
          .join("text")
          .attr("class", "wicket-text")
          .attr("x", (d) => d.x)
          .attr("y", (d) => d.y + 10)
          .attr("text-anchor", "middle")
          .attr("fill", "black")
          .style("font-size", "2px")
          .text((d, i) => d.match[4]);

        function transition() {
          const d = data[Math.floor(Math.random() * data.length)];
          const i = d3.interpolateZoom(currentTransform, [
            d.x,
            d.y,
            radius * 2 + 1,
          ]);

          g.transition()
            .delay(4000)
            .duration(i.duration)
            .attrTween(
              "transform",
              () => (t) => transform((currentTransform = i(t)))
            )
            .on("end", transition);
        }

        function transform([x, y, r]) {
          return `
      translate(${width / 2}, ${height / 2})
      scale(${height / r})
      translate(${-x}, ${-y})
    `;
        }

        transition(); // Start the initial transition
        return svg.node();
      }
      
      const chartContainer = document.createElement("div");
      document.body.appendChild(chartContainer);
      chartContainer.appendChild(chart());
    }
  }
}
