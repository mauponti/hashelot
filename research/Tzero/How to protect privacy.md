# How to protect privacy while fighting a pandemic

Imagine you are a superhero who is fighting against an invisible crime organization that operates all across the world.

As all superheroes do, **you need to hide your identity**, but the good news is you're not alone in this fight. You can count on a league of superhero friends to detect and control new crimes.

Each one of you has a secret identity. Even better, your secret identities can change every 10 minutes.

![With great pseudonyms comes great privacy!](/images/superheroes.png)

During one guard duty of yours, you realize that you might need to send each other a message and you wonder: is there a way to do it without the risk of revealing your secret identities, let alone your real ones?

Suppose now there's a trusted radio station that can broadcast encrypted snippets of data. Those snippets are useless to the majority of those who listen to the broadcast, but they actually mean something to certain superheroes.

This is, in a nutshell, the idea behind the T0 Protocol (*tentative title*).

**Contact tracing apps appear to be a valid tool in detecting** and controlling **new infections** while fighting the spread of a pandemic, but they commonly raise concerns regarding users privacy.

T0 is a privacy-preserving protocol for exclusive local storage of contact tracing data in the form of **time-varying pseudonyms** (i.e. contact data is only saved on a user's device in a cryptographic hashed representation and not stored on centralized servers). The protocol allows then to verify local data in an asynchronous fashion against centralized alerts.

Bluetooth Low Energy (BLE) Advertisement Channels are used to achieve a proximity communication without a pairing process.

**Every 10 minutes a user's device employs a new pseudonym**, a secret identity, and broadcasts it on its BLE advertisement channels to whoever might come in proximity with it.

The pseudonyms come in the form of tiny unintelligible values, the results of an operation called **cryptographic hash function** (CHF), which is easy to evaluate and has a fixed short length. Furthermore a CHF is designed to make collisions (same result for different entries) highly unlikely and to be practically infeasable to invert, that is **if you only know a hash value, you won't be able to determine a corresponding entry**.

Every time there is a contact or in other words when two users get in reciprocal proximity, the involved **devices register the pseudonym of the other party**, plus another time-varying figure, a random value that indeed determines the pseudonym variation itself.

No contact data ends up on a central server and no other personal details are shared by the two parties, since the whole process doesn't even involve explicitly exchanging data. In fact, what the users do **it's exactly like listening to a radio station and noting down a few lyrics of the song that's being played**. The words of that song do not even make sense, unless one has the key to unlock them.

If a user tests positive at a later time he or she just needs to give to the competent health agency **the key that once shared allows other users to know if they have come in contact with a potentially contagious person**, it lets them understand the lyrics of the song.

The design of the protocol preserves the core generator of pseudonyms, hence the identity of a user, even in the event of a positive test. The snippet of data given to the health agency, the same data that will be broadcast to every other T0 user to alert them, is yet again protected by the properties of the cryptographic hash function.

Finally, some may argue that they are not superheroes and they don't feel the urgency to hide their identity. They might even rely on the good old **nothing to hide** argument to reinforce their position, but this is not a skeleton-in-a-cupboard sort of thing.

What **people** don't realize is that they **do have something to hide, just not something they necessarily need to be ashamed of**. A sum of information that may individually appear harmless to one, could still lead to abuses and manipulation if it ended up in the wrong hands.
