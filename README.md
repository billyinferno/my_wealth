# myWealth

Bloomberg is behind paywall so I create my own investment tracker.

## So what you need?

Definitely a backend that serve your purpose, as most backend need to use API key to get the data, so I will leave the backend to your imagination.

## Web Again?

<strong>What WEB APP AGAIN? 😡</strong>

Yes, and why not, it's buggy, the keyboard sometimes dissapear, the render sometimes doing funky stuff, but you just need to close the web app and reload again and it works. And when you have changes, it will automatically push without any needed for use (a.k.a me) to re-install the application.

Is it <i>BUGGY</i>? Yes ✔️

Is it <i>CONVENIENCE</i>? Yes ✔️

And since I am the only who using it, then the person who will blame and be blamed will be just me only, so Web App it is.

## I don't want to use Web App

Sure, just try compile it to native as this is using Flutter so you can do what you want.

## Enough, so what is it looks like?

### Watchlist

Here you can see all the watchlist of all your investment, and see whether the status is Green (good you gain profit), or Red (good, more chance to buy low).

<img src="https://user-images.githubusercontent.com/20193342/154708809-347a3f83-9243-4712-9476-1791afd426d7.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154708809-347a3f83-9243-4712-9476-1791afd426d7.png" width="350" />

If you tap the watchlist item it will expand, and show you all the detail from that watchlist (if any):
<img src="https://user-images.githubusercontent.com/20193342/154709847-2e9757ef-8405-4495-b4a9-519b75ea811e.png" data-canonical-src="hhttps://user-images.githubusercontent.com/20193342/154709847-2e9757ef-8405-4495-b4a9-519b75ea811e.png" width="350" />

Each of the watchlist item also a slideable widget, so you can slide it to see options to:
<ul>
  <li>Add new detail</li>
  <li>View watchlist detail</li>
  <li>View company detail</li>
  <li>Delete watchlist</li>
</ul>

In here you can also "Add Symbol" to add ticker/symbol of your investment

|Search Symbol|Search Symbol Result|Add Symbol|
|-------------|--------------------|----------|
|<img src="https://user-images.githubusercontent.com/20193342/154709112-6c918d37-52c6-4468-933a-422c01c79e98.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154709112-6c918d37-52c6-4468-933a-422c01c79e98.png" width="350" />|<img src="https://user-images.githubusercontent.com/20193342/154709177-78e11742-01bb-4476-bcf9-ee8adef72864.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154709177-78e11742-01bb-4476-bcf9-ee8adef72864.png" width="350" />|<img src="https://user-images.githubusercontent.com/20193342/154709254-e0be95ea-8161-4318-88c6-5fe092f579e4.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154709254-e0be95ea-8161-4318-88c6-5fe092f579e4.png" width="350" />|

If you double tap the watchlist, you will automatically route to the watchlist information:

<img src="https://user-images.githubusercontent.com/20193342/154710194-30c83e75-ee57-41c5-a64b-0432450e1f98.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154710194-30c83e75-ee57-41c5-a64b-0432450e1f98.png" width="350" />

Each the watchlist detail item also a slideable widget, where you can perform Edit or Delete the watchlist detail using the action button on the slideable:

<img src="https://user-images.githubusercontent.com/20193342/154710448-abd1f7a6-e501-44a2-89c0-2003db8c5422.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154710448-abd1f7a6-e501-44a2-89c0-2003db8c5422.png" width="350" />

You can also use the Add Detail button on the page to add detail item on the watchlist.

|Add Detail|Edit Detail|
|----------|-----------|
|<img src="https://user-images.githubusercontent.com/20193342/154710696-3d292aff-0072-44d8-9256-926112ed5bfc.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154710696-3d292aff-0072-44d8-9256-926112ed5bfc.png" width="350" />|<img src="https://user-images.githubusercontent.com/20193342/154710755-86f46e2e-7901-4f32-a2eb-6a6a57900771.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154710755-86f46e2e-7901-4f32-a2eb-6a6a57900771.png" width="350" />|

### Favourites

In favourites page, it will show you all the symbol/ticker that you interested in. To add favourites, you can tap the ➕ button, which will direct you to the Favour List page.

|Favourites|Favourites List|
|----------|---------------|
|<img src="https://user-images.githubusercontent.com/20193342/154711112-9d98759c-4333-41eb-9d45-ea8f5a27f9f1.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154711112-9d98759c-4333-41eb-9d45-ea8f5a27f9f1.png" width="350" />|<img src="https://user-images.githubusercontent.com/20193342/154711173-469b83fa-eff8-4a7c-84be-b920b44ca0f0.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154711173-469b83fa-eff8-4a7c-84be-b920b44ca0f0.png" width="350" />|

### Company Details

When you tap favourites item, or cliek the (...) on the watchlist slideable, it will direct you to the Company Detail page, which will show you all the information for the company:

<img src="https://user-images.githubusercontent.com/20193342/154711471-efc4a61d-5c12-4045-9154-909baf1d636f.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154711471-efc4a61d-5c12-4045-9154-909baf1d636f.png" width="350" />

## Index

Same as Favourites, but instead it will show you the Indices information, and when you tap the item it will open the Index Detail page that will showed you all the information on that particular indices.

|Index List|Index Detail|
|----------|------------|
|<img src="https://user-images.githubusercontent.com/20193342/154711751-e65edf9e-264a-4f01-bf37-20fd443ea42f.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154711751-e65edf9e-264a-4f01-bf37-20fd443ea42f.png" width="350" />|<img src="https://user-images.githubusercontent.com/20193342/154711829-e623fac0-30bb-4fcc-8dd0-73009593c40a.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154711829-e623fac0-30bb-4fcc-8dd0-73009593c40a.png" width="350" />|

### User

On the user page, you can edit the Risk Factor, which will be used to calculate the "Green" or "Red" marked on each item on this application. The more the Risk Factor, it means that you able to bear lose for more, and less Risk Indicator it means that we want to play it "safe" instead push it to the limit.

|User|Risk Factor|
|----|-----------|
|<img src="https://user-images.githubusercontent.com/20193342/154712201-dd9b23cf-c901-44c8-b1cf-0ba6eb962500.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154712201-dd9b23cf-c901-44c8-b1cf-0ba6eb962500.png" width="350" />|<img src="https://user-images.githubusercontent.com/20193342/154712270-66cb296d-a51f-4305-976a-b47421ec0845.png" data-canonical-src="https://user-images.githubusercontent.com/20193342/154712270-66cb296d-a51f-4305-976a-b47421ec0845.png" width="350" />|

## Final

That's all folks...now go off create the backhend...😁
