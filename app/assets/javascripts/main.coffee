class Task extends Backbone.Model
  initialize: ->
  defaults:
    id: 0
    label: ""

class TasksCollection extends Backbone.Collection
  model: Task
  url: "/ajax/tasks"


class AppView extends Backbone.View
  initialize: ->
    @createNewTaskView = new CreateNewTaskView
      el: $("#newTaskForm")
    @createNewTaskView.appView = this
    this.tasks = $.map $("li",@el), (item) ->
      taskItemView = new TaskItemView
        el: $(item)
        appView: this

class TaskItemView extends Backbone.View
  initialize: ->
    @id = @el.attr("data-task-id")

  events:
    "click a" : "deleteTask"

  deleteTask: (e)->
    id = @id
    e.preventDefault()
    jsRoutes.controllers.Application.deleteTaskAJAX(id).ajax
      type: "GET"
      context: this
      success: (tpl) ->
        $("body").find("li[data-task-id="+id+"]").remove()
        @appView.tasks = (item for item in @appView.tasks when item.id isnt id)
        $("body").find("h1").html("You have "+@appView.tasks.length+" tasks!")
      error: (err) ->
        alert "Something went wrong:" + err
    false

class CreateNewTaskView extends Backbone.View
  initialize: ->

  events:
    "click #newTaskSubmit": "createNew"
    "submit": "createNew"

  createNew: (e) ->
    e.preventDefault()
    $(document).focus() # temporary disable form
    taskLabel = $("input[id=taskLabel]", @el).val()
    appView = @appView
    jsRoutes.controllers.Application.newTaskAJAX().ajax
      type: "POST"
      context: this
      data:
        label: taskLabel
      success: (tpl) ->
        newTask = new TaskItemView
          el: $(tpl)
        newTask.appView = appView
        appView.tasks.push(newTask)
        $("body").find("ul").append(newTask.el)
        $("body").find("h1").html("You have "+appView.tasks.length+" tasks!")
        @el.find("input[id=taskLabel]").val("").first().focus()
      error: (err) ->
        alert "Something went wrong:" + err
    false

$ ->
  appView = new AppView
    el: $("body")