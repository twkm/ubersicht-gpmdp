# [GDMDP Widget](https://github.com/twkm/ubersicht-gpmdp)
# Created by [Troy Meier](https://github.com/twkm)

# Get dock size and resize widget accordingly
command: '''
osascript <<EOS
  global dock_width, dock_height, dock_bottom

  tell application "System Events" to tell process "Dock"
    global dock_width, dock_height
    set dock_dimensions to size in list 1
    set dock_width to item 1 of dock_dimensions
    set dock_height to item 2 of dock_dimensions
  end tell

  tell application "System Events"
    global dock_bottom
    set dock_bottom to (screen edge of dock preferences is bottom)
  end tell

  if dock_bottom then
      "<div id='wrapper' style='width: calc(50% - ("& dock_width &"px / 2) - 8px); height: calc("& dock_height &"px - 8px); font-size: "& dock_height &"px;'>"
  else
      "<div id='wrapper' style='width: 33%; height: calc(7vh - 8px); font-size: 7vh;'>"
  end if
EOS

PHP=$(which php)
read -r -d '' php_script <<'EOPHP'
// Get now playing data from GPMDP JSON API
$raw_data = file_get_contents($_SERVER['HOME']."/Library/Application Support/Google Play Music Desktop Player/json_store/playback.json");
$json = json_decode($raw_data,1);
if ($json['playing'] == true) {
    $play_width = $json['time']['current'] / $json['time']['total'] * 100;
    if (empty($json['song']['artist'])) {
      $json['song']['artist'] = '&nbsp;';
    }
    if (empty($json['song']['title'])) {
      $json['song']['title'] = '&nbsp;';
    }
    echo '<div id="artist">'. $json['song']['artist'] .'</div>';
    echo '<div id="track">'. $json['song']['title'] .'</div>';
    echo '<div id="player"><div id="played" style="width: '. $play_width  .'%; max-width: 100%;"></div>';
}
EOPHP
player=$($PHP -r "$php_script")
echo $player '</div>'
'''

# Refresh every .5 second for a smooth player bar
refreshFrequency: 500

render: (output) -> """
 #{output}
"""

style: """
  width: 100%
  color: #FFF
  font-family: Helvetica Neue
  bottom: 0
  right: 0
  margin: 0
  padding: 0
  text-align: left
  vertical-align: middle;

  div#wrapper
    float: right
    padding: 4px

  div#track
    margin-bottom: 4px
    font-size: calc(55% - 11.5px)
    line-height: 100%
    font-weight: 800
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis

  div#artist
    margin-bottom: 4px
    font-size: calc(45% - 7.5px)
    line-height: 100%;
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis

  div#player
    width: 100%
    height: 3px
    background-color: #333

  div#played
    height: 3px
    background-color: #777
    border-right: 3px solid #0da900
"""
