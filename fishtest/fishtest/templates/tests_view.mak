<%inherit file="base.mak"/>

<%namespace name="base" file="base.mak"/>

<h3>${run['args']['new_tag']} vs ${run['args']['base_tag']} ${base.diff_url(run)}</h3>

<div class="row-fluid">
<div class="span4">
<%include file="elo_results.mak" args="run=run" />
</div>
</div>

<div class="row-fluid">

<div class="span8">
  <h4>Details</h4>

  <table class="table table-condensed">
  %for arg in run_args:
    %if len(arg[2]) == 0:
    <tr><td>${arg[0]}</td><td>${arg[1]}</td></tr>
    %else:
    <tr><td>${arg[0]}</td><td><a href="${arg[2]}" target="_blank">${arg[1]}</a></td></tr>
    %endif
  %endfor
  </table>
</div>

<div class="span4">
  <h4>Actions</h4>
%if not run['finished']:
  <form action="/tests/stop" method="POST" style="display:inline">
    <input type="hidden" name="run-id" value="${run['_id']}">
    <button type="submit" class="btn btn-danger">
      Stop
    </button>
  </form>
%endif
  <a href="/tests/run?id=${run['_id']}">
    <button class="btn">Reschedule</button>
  </a>

  <hr>

  <form class="form" action="/tests/modify" method="POST">
    <label class="control-label">Number of games:</label>
    <input name="num-games" value="${run['args']['num_games']}">

    <label class="control-label">Adjust priority (higher is more urgent):</label>
    <input name="priority" value="${run['args']['priority']}">

    <input type="hidden" name="run" value="${run['_id']}" />
    <button type="submit" class="btn btn-primary">Modify</button>
  </form>
</div>

</div>

%if 'clop' in run['args']:
<h3>Games</h3>
<table class='table table-striped table-condensed'>
 <thead>
  <tr>
   <th>Idx</th>
   <th>Pid</th>
   <th>Seed</th>
   <th>White</th>
   <th>Parameters</th>
   <th>Result</th>
  </tr>
 </thead>
 <tbody>
  %for game in run['games']:
  <%
    idx = game['task_id'] if len(game['task_id']) > 0 else 'pending'
    parameters = ['%s=%s'%(x[0], x[1]) for x in game['params']]

    if idx != 'pending':
      active_style = 'info'
    elif len(game['result']) > 0:
        active_style = 'error'
    else:
      active_style = ''
  %>
  <tr class="${active_style}">
   <td>${idx}</td>
   <td>${game['pid']}</td>
   <td>${game['seed']}</td>
   <td>${game['white']}</td>
   <td>${',  '.join(parameters)}</td>
   <td>${game['result']}</td>
  </tr>
  %endfor
 </tbody>
</table>
%endif

<h3>Tasks</h3>
<table class='table table-striped table-condensed'>
 <thead>
  <tr>
   <th>Idx</th>
   <th>Worker</th>
   <th>Last Updated</th>
   <th>Played</th>
   <th>Wins</th>
   <th>Losses</th>
   <th>Draws</th>
   <th>Crashes</th>
  </tr>
 </thead>
 <tbody>
  %for idx, task in enumerate(run['tasks']):
  <%
    stats = task.get('stats', {})
    if 'stats' in task:
      total = stats['wins'] + stats['losses'] + stats['draws']
    else:
      continue

    if 'worker_info' in task:
      machine_info = task['worker_info'].get('username', '') + '-' + str(task['worker_info']['concurrency']) + 'cores'
    else:
      machine_info = '-'

    if task['active'] and task['pending']:
      active_style = 'info'
    elif task['active'] and not task['pending']:
      active_style = 'error'
    else:
      active_style = ''
  %>
  <tr class="${active_style}">
   <td>${idx}</td>
   <td>${machine_info}</td>
   <td>${str(task.get('last_updated', '-')).split('.')[0]}</td>
   <td>${total} / ${task['num_games']}</td>
   <td>${stats.get('wins', '-')}</td>
   <td>${stats.get('losses', '-')}</td>
   <td>${stats.get('draws', '-')}</td>
   <td>${stats.get('crashes', '-')}</td>
  </tr>
  %endfor
 </tbody>
</table>

