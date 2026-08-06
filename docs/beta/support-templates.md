# Support email templates

Fill `<...>`; keep replies short and human. Every template ends with a
real question so the thread stays alive.

## Bug report — acknowledged

> Subject: Re: <their subject>
>
> Thanks — this is exactly the kind of report we need. I've logged it
> (<issue link>) and can reproduce it / am trying to reproduce it on
> <platform>.
>
> <If known: what's happening in one sentence, no jargon.>
> <If workaround exists: one sentence.>
>
> A fix is planned for <rc.N / "the next build">. I'll reply here when
> it ships. Did you notice anything else odd right before it happened?

## Bug fixed — follow-up

> Subject: Fixed in <version>: <short description>
>
> The issue you reported (<one line>) is fixed in <version> —
> <install/update line for their platform>. The changelog line is:
> "<CHANGELOG entry>".
>
> Thanks for making the app better. Anything else been bugging you?

## Feature request — answer (yes / later / no)

> Subject: Re: <their subject>
>
> Good idea — logged as <issue link>.
> [YES] It fits what we're building; expect it around <milestone>.
> [LATER] We want it, but it needs <real prerequisite — e.g. real
> price feeds> first, so it's parked with a note, not forgotten.
> [NO] We're deliberately not doing this because <honest reason —
> e.g. it would require collecting data we've promised not to>.
>
> What problem were you hitting when you thought of it? Sometimes we
> can solve that a simpler way.

## Quiet tester — check-in (send once)

> Subject: Still shopping with us?
>
> You've been quiet for a couple of weeks — totally fine either way.
> If the app lost you, one sentence about *where* it lost you would be
> the most valuable feedback we could get. If you're just busy,
> ignore this. If you'd like out of the beta, say the word and we'll
> remove you (your data stays deletable in-app any time).

## Can't-reproduce — need more info

> Subject: Re: <their subject>
>
> I can't reproduce this yet on <platform>. Could you send:
> 1. Settings → About version (e.g. "1.0.0 (12)"),
> 2. demo or account mode,
> 3. what you tapped right before it happened?
> If the app crashed, Settings → Send feedback pre-fills the error
> details — you'll see exactly what's included before sending.

## Offboarding

> Subject: Thanks for testing Grocery Shopping Assistant
>
> We're wrapping up your beta participation — thank you, genuinely:
> testers like you are why <one concrete fixed thing> got fixed.
>
> Housekeeping: your data stays under your control — Settings →
> Export my data (JSON) and Settings → Delete account (immediate,
> permanent) work as long as you keep the app. If you'd rather we
> remove your account server-side, reply and we'll do it.
>
> What ships next: <one line from the roadmap>. If you'd like an
> invite when we launch publicly, say so and you'll be first.

## Data / privacy question

> Subject: Re: <their subject>
>
> Short version: demo mode sends nothing anywhere; with an account
> your data is scoped to you, exportable (Settings → Export my data)
> and deletable (Settings → Delete account, immediate and cascading).
> The full policy is here: <PRIVACY.md link>. Every analytics event we
> record is listed here: <Observability.md link>. Was there a specific
> concern I can answer directly?
