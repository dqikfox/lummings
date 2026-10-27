"""Shared Tomorrow Crew vector artwork for runtime and export."""

PROFILES = {'lumo': {'title': 'The Hyperfixation Gremlin', 'color': '#ed4054'}, 'lila': {'display_name': 'Luna', 'title': 'The Spooky Poet', 'color': '#b59aff'}, 'pip': {'display_name': 'Sprout', 'title': 'The Quiet Garden Sprite', 'color': '#57db91'}, 'nori': {'title': 'The Cosmic Weirdo', 'color': '#75d8ef'}, 'moki': {'title': 'The Chaos Gremlin', 'color': '#ff83bd'}}
MOODS = ['amused', 'calm', 'cryptic', 'curious', 'distant', 'drowsy', 'embarrassed', 'excited', 'happy', 'mischievous', 'playful', 'sleepy', 'thoughtful', 'tired', 'warm', 'watchful']
SHAPES = {
'lumo':'M120 56 C162 56 169 93 181 123 C209 189 173 214 120 214 C67 214 31 189 59 123 C71 93 78 56 120 56Z',
'lila':'M120 46 C140 69 186 89 184 147 C182 192 159 213 120 213 C81 213 58 192 56 147 C54 89 100 69 120 46Z',
'pip':'M99 67 C151 48 184 83 180 133 C177 163 186 199 147 210 C102 226 61 204 58 165 C54 126 58 82 99 67Z',
'nori':'M120 46 C135 78 183 96 185 151 C186 194 160 215 120 215 C80 215 54 194 55 151 C57 96 105 78 120 46Z',
'moki':'M65 91 Q47 60 82 68 Q100 44 121 63 Q154 41 166 75 Q198 74 183 106 Q211 130 188 154 Q198 189 166 193 Q149 225 118 210 Q83 226 72 199 Q39 191 51 161 Q28 135 56 115Z'}

def render(name, mood, blink=False, glow=True):
 p=PROFILES[name]; c=p['color']; ink='#25334a'
 sleepy=mood in ('sleepy','drowsy','tired'); wink=mood in ('playful','mischievous','cryptic'); joyful=mood in ('happy','excited','amused')
 def path(d,fill,stroke=ink,width=3): return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>'
 behind=''; front=''
 if name=='lumo':
  behind='<ellipse cx="120" cy="46" rx="60" ry="23" fill="none" stroke="#9c92ff" stroke-width="2" stroke-dasharray="9 7" opacity=".8"/>'
  front=path('M63 168 L79 156 L104 170 L120 199 L137 170 L160 156 L177 170 L171 211 L68 211Z','#29284e')+path('M78 157 L103 171 L110 183 L92 177Z','#fff0d0')+path('M159 157 L138 171 L130 183 L147 177Z','#fff0d0')+path('M152 177 L155 183 L162 184 L157 189 L158 196 L151 193 L145 197 L146 189 L141 185 L148 183Z','#ffd378','none')+path('M74 207 L69 224 L108 224 L109 208Z','#334159')+path('M130 208 L132 224 L172 224 L166 207Z','#334159')+path('M70 221H108 M133 221H171','none','#fff0d0',4)+path('M64 93 Q54 64 77 48 L69 36 L94 39 L99 17 L115 31 Q147 4 181 25 L169 43 L188 44 L176 63 Q145 77 110 64 Q84 65 64 93Z','#682d48','#682d48')+path('M82 53 Q119 34 158 29 M98 58 Q130 42 167 43','none','#ff786e',4)
  front+=path('M82 176 Q120 194 158 176','none','#72e0eb',4)+path('M96 169 L94 181 L104 186 M145 170 L147 181 L138 185','none','#b49aff',2)+path('M62 188 Q67 177 79 184 L90 184 Q101 177 107 188 L110 202 Q108 210 100 202 L92 198 L79 198 L70 205 Q61 209 59 202Z','#292448','#80e8f4',2)+'<circle cx="76" cy="190" r="4" fill="#83f0e4"/><circle cx="94" cy="190" r="3" fill="#b79cff"/><path d="M184 99l5 10 11 2-8 8 1 11-10-6-10 6 2-12-8-8 12-2z" fill="#bfa4ff" stroke="#76e7ee" stroke-width="2"/><path d="M184 89V78 M205 106L215 100 M161 101L153 92" stroke="#85eff4" stroke-width="2"/>'
 if name=='lila':
  behind=path('M94 83 Q33 75 36 22 Q74 34 99 66Z',c)+path('M143 80 Q209 77 211 32 Q174 34 140 63Z',c)+path('M160 171 Q218 159 208 194 Q196 220 220 211 Q206 238 182 214 L150 195Z','#7769c7')
  front=path('M68 168 Q118 187 170 165 L168 182 Q121 202 71 184Z','#6d64b7')+path('M174 147 L203 101 L210 105 L182 152Z','#ffe1a2')+path('M200 100 L204 89 L211 103Z','#fff5cd')+'<path d="m85 179 4-5 4 5-4 5z" fill="#fff0b6"/>'
 if name=='pip':
  behind=path('M88 87 Q38 53 66 11 Q108 36 105 80Z','#55ba7d')+path('M128 74 Q125 24 164 12 Q184 56 147 85Z','#79dc91')+path('M71 29L91 76M160 29L140 76','none','#267c63',2)
  front=path('M71 192 Q64 208 58 211 L58 225 Q85 234 111 224 L110 204Z','#dfab6a')+path('M132 202 L130 223 Q157 232 184 223 L182 209 L169 193Z','#527a91')+path('M77 164 Q120 179 164 161','none','#8e6542',5)+'<circle cx="121" cy="181" r="13" fill="#e8b96f" stroke="#805c36" stroke-width="3"/>'+path('M117 186 L122 173 L126 184Z','#fff4cb','none')
 if name=='nori':
  behind=path('M82 100 Q35 65 66 21 Q68 61 109 65Z','#528cbd')+path('M142 69 Q178 62 179 24 Q213 74 161 100Z','#528cbd')
  front=path('M70 164 Q112 189 168 164 L164 184 Q117 210 74 181Z','#487fab')+'<path d="M91 174a9 9 0 1 0 11 11 9 9 0 0 1-11-11" fill="#ffe5a3"/>'+path('M176 157 Q198 152 197 173','none','#466b91')+'<rect x="181" y="171" width="28" height="36" rx="8" fill="#ffe5a3" stroke="#466b91" stroke-width="4"/><ellipse cx="195" cy="188" rx="7" ry="11" fill="#fff8d6"/><circle cx="195" cy="188" r="26" fill="#ffe4a3" opacity=".12"/>'
 if name=='moki':
  behind=path('M74 90 L53 38 Q90 29 102 78Z',c)+path('M144 77 L166 14 L174 43 L196 36 L177 88Z',c)+path('M58 39L72 61L89 46','#e66b9c')
  front=path('M76 165 Q122 187 167 163 L166 183 Q123 208 75 184Z','url(#checker)')+path('M157 181 Q206 185 191 225 L175 216 L169 228 L151 190Z','url(#checker)')
 eyes=''
 for x in (94,146):
  if blink or sleepy or (wink and x==146): eyes+=path(f'M{x-11} 122 Q{x} {130 if sleepy else 115} {x+11} 122','none',ink,4)
  else:
   r=13 if joyful else 11
   dx,dy={'curious':(2,-2),'watchful':(4,0),'distant':(-4,1),'thoughtful':(-2,-3),'embarrassed':(0,3),'warm':(0,-1)}.get(mood,(0,0))
   eyes+=f'<ellipse cx="{x+dx}" cy="{122+dy}" rx="{r}" ry="{r+2}" fill="{ink}"/><circle cx="{x+dx-3}" cy="{118+dy}" r="4" fill="#fff"/><circle cx="{x+dx+4}" cy="{127+dy}" r="2" fill="#fff" opacity=".6"/>'
 mouth=('<ellipse cx="120" cy="150" rx="6" ry="8" fill="#25334a"/>' if mood in ('sleepy','excited') else path('M107 148 Q120 161 135 146' if wink else 'M108 148 Q120 158 132 148','none',ink,3))
 if name=='lumo' and mood in ('curious','warm','playful','mischievous','happy','cryptic'): mouth=path('M106 150 Q122 163 138 145','none',ink,3)
 if mood=='tired': mouth=path('M110 154 Q120 147 130 154','none',ink,3)
 if mood=='distant': mouth=path('M112 151 L128 151','none',ink,3)
 brows=path('M83 101Q94 94 104 100 M136 100Q148 94 158 101','none',ink,2) if mood in ('curious','excited','watchful') else ''
 if name=='lumo' and mood in ('curious','warm','playful','mischievous','cryptic'): brows=path('M82 101 Q94 93 105 99 M137 103 Q148 100 159 104','none',ink,3)
 if mood in ('thoughtful','embarrassed'): brows=path('M82 102 Q94 105 104 100 M136 100 Q148 105 158 102','none',ink,2)
 halo = '<circle cx="120" cy="126" r="115" fill="url(#halo)"/>' if glow else ''
 return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240" width="240" height="240" role="img" aria-label="{p.get('display_name', name.title())} {p['title']} — {mood}"><defs><radialGradient id="body"><stop stop-color="#fff3df" offset="0"/><stop stop-color="{c}" offset=".6"/><stop stop-color="{c}" offset="1"/></radialGradient><radialGradient id="halo"><stop stop-color="{c}" stop-opacity=".25"/><stop stop-color="{c}" stop-opacity="0" offset="1"/></radialGradient><pattern id="checker" width="16" height="16" patternUnits="userSpaceOnUse"><rect width="16" height="16" fill="#fff1d9"/><path d="M0 0H8V8H0ZM8 8H16V16H8Z" fill="#665087"/></pattern></defs>{halo}<ellipse cx="120" cy="229" rx="70" ry="5" fill="#1a2440" opacity=".12"/>{behind}{path(SHAPES[name],'url(#body)',c)}<ellipse cx="57" cy="169" rx="12" ry="18" fill="{c}" transform="rotate(25 57 169)"/><ellipse cx="181" cy="167" rx="11" ry="17" fill="{c}" transform="rotate(-25 181 167)"/><ellipse cx="78" cy="143" rx="11" ry="6" fill="#ed8795" opacity=".32"/><ellipse cx="163" cy="143" rx="11" ry="6" fill="#ed8795" opacity=".32"/>{eyes}{brows}{mouth}{front}<g fill="#fff5da" opacity=".8"><circle cx="104" cy="173" r="1.7"/><circle cx="135" cy="169" r="1.5"/></g></svg>'''

