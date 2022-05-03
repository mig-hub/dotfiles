function! timehelpers#HMToSec(val)
  let hm = map(split(a:val, ':'), {_, v -> str2nr(v)})
  return hm[0] * 3600 + hm[1] * 60
endfunction

function! timehelpers#SecToHM(val)
  let hr = a:val / 3600
  let mn = (a:val - hr * 3600) / 60
  return printf('%s:%s', hr, mn)
endfunction

function! timehelpers#TableModeSumTime(range) abort
  let vals = tablemode#spreadsheet#cell#GetCellRange(a:range)
  " let total = reduce(map(vals, {_, v -> timehelpers#HMToSec(v)}), {acc, v -> acc + v})
  let total = 0
  for val in vals
    let total += timehelpers#HMToSec(val)
  endfor
  return timehelpers#SecToHM(total)
endfunction

