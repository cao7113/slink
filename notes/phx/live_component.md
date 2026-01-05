# LiveComponent

LiveComponents are defined by using Phoenix.LiveComponent and are used by calling Phoenix.Component.live_component/1 in a parent LiveView. They run inside the LiveView process but have their own state and life-cycle. 
For this reason, they are also often called "stateful components". 