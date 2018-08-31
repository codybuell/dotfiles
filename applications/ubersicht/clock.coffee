command: "date '+%l:%M:%S %p'"

refreshFrequency: 1000

render: (output) -> """
  #{output}
"""

style: """
  width: 200px
  box-sizing: border-box
  margin: 0
  padding: 0
  top: 10px
  left: 10px
  text-align: center
  font-family: Source Code Pro
  font-weight: 200
  font-size: 25px
  color: rgba(66,66,66,0.5)
"""
