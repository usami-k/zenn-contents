#import "@preview/cetz:0.2.2"

#set text(font: "YuKyokasho Yoko")
#show math.equation: set text(font: "STIX Two Math")
#show raw: set text(font: "0xProto")

#cetz.canvas(
  length: 1.5cm,
  {
    import cetz.draw: *
    set-style(content: (padding: 0.1))
    // 座標軸
    line((-1.8, 0), (1.8, 0), stroke: (dash: "dashed"), mark: (end: "straight", scale: 2), name: "axis-x")
    content("axis-x.end", [$x$], anchor: "west")
    line((0, -1.4), (0, 1.8), stroke: (dash: "dashed"), mark: (end: "straight", scale: 2), name: "axis-y")
    content("axis-y.end", [$y$], anchor: "south")
    // 単位円
    circle((0, 0), radius: 1, stroke: (dash: "dashed"), name: "circle")
    content("circle.east", [$1$], anchor: "north-west")
    // alpha
    circle((35deg, 1), radius: 0.05, fill: black, name: "alpha")
    content("alpha", [$alpha$], anchor: "south-west")
    line((0, 0), "alpha", stroke: (dash: "dashed"))
    cetz.angle.angle((0, 0), (1, 0), "alpha", radius: 0.7, label: $theta$)
    // beta
    circle((110deg, 1.5), radius: 0.05, fill: red, name: "beta")
    content("beta", [#text(fill: red)[$beta$]], anchor: "south")
    line((0, 0), "beta")
    circle((145deg, 1.5), radius: 0.05, fill: red, name: "alphabeta")
    content("alphabeta", [#text(fill: red)[$alpha beta$]], anchor: "south-east")
    line((0, 0), "alphabeta")
    cetz.angle.angle((0, 0), "beta", "alphabeta", radius: 0.7, label: $theta$)
    cetz.angle.angle((0, 0), "beta", "alphabeta", radius: 1.5, mark: (end: ">", scale: 2), stroke: red)
  },
)

#pagebreak()

#cetz.canvas(
  length: 1.5cm,
  {
    import cetz.draw: *
    set-style(content: (padding: 0.1))
    ortho({
      // 補助線
      line((-1.8, 0, 0), (1.8, 0, 0), stroke: (dash: "dashed"))
      line((0, -1.8, 0), (0, 1.8, 0), stroke: (dash: "dashed"))
      // 直線 l
      line((0, 0, -2.5), (0, 0, 2.5), name: "line")
      content("line.end", [$l$], anchor: "south")
      line((0.3, 0, 1.4), (0.3, 0, 2.4), mark: (end: "straight", scale: 2), name: "vector")
      content("vector.end", [$(x_l, y_l, z_l)$], anchor: "north")
      // 単位円
      circle((0, 0, 0), radius: 1, stroke: (dash: "dashed"), name: "circle")
      set-style(content: (padding: 0.1))
      // beta
      circle((15deg, 1.5), radius: 0.05, fill: red, name: "beta")
      content("beta", [#text(fill: red)[$beta$]], anchor: "west")
      line((0, 0), "beta")
      circle((75deg, 1.5), radius: 0.05, fill: red, name: "alphabeta")
      content("alphabeta", [#text(fill: red)[$alpha beta alpha^*$]], anchor: "south")
      line((0, 0), "alphabeta")
      cetz.angle.angle((0, 0), "beta", "alphabeta", radius: 0.7, label: $theta$)
      cetz.angle.angle((0, 0), "beta", "alphabeta", radius: 1.5, mark: (end: ">", scale: 2), stroke: red)
    })
  },
)
