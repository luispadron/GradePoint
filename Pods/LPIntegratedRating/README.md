## LPIntegratedRating

<h3 align="center">An integrated rating view for iOS built with Swift 4</h3>

<p align="center">
<img src="https://raw.githubusercontent.com/luispadron/LPIntegratedRating/master/.github/Demo.png" width="500"/>  
</p>

<p align="center">
<img src="https://raw.githubusercontent.com/luispadron/LPIntegratedRating/master/.github/ViewFlow.png" width="500"/>  
</p>

## Features

- Stops users feeling annoyed from pop ups asking for ratings.
- Customizable for your app needs.
- Easy to use with `UITableView`'s and `UICollectionViews`'s.

## Installation

### Cocoapods (recommended)

1. Install [CocoaPods](https://cocoapods.org)
2. Add this pod to your `Podfile`

	```ruby
	target 'Example' do
		use_frameworks!

		pod 'LPIntegratedRating'
	end
	```
3. Run `pod install`
4. Open up the `.xcworkspace` that CocoaPods created
5. Import `LPIntegratedRating` into any source file where it's needed

### From Source

1. Simply download the source from [here](https://github.com/luispadron/LPIntegratedRating/tree/master/LPIntegratedRating) and add it to your Xcode project

## Usage

### Delegate conformance

You must conform to the delegate in order to customize the view.

Here is an example:

```swift
extension ViewController: LPRatingViewDelegate {
    
    func ratingViewDidFinish(with status: LPRatingViewCompletionStatus) {
        switch status {
        case .ratingApproved:
            print("Rating approved")
        case .ratingDenied:
            print("Rating denied")
        case .feedbackApproved:
            print("Feedback approved")
        case .feedbackDenied:
            print("Feedback denied")
        }
    }
    
    func ratingViewConfiguration(for state: LPRatingViewState) -> LPRatingViewConfiguration? {
        switch state {
        case .initial:
            let title = NSAttributedString(string: "Enjoying this app?",
                                           attributes: [.foregroundColor: UIColor.white])
            let title2 = NSAttributedString(string: "Yes!",
                                            attributes: [.foregroundColor: UIColor(red: 0.376, green: 0.788, blue: 0.773, alpha: 1.00)])
            let title3 = NSAttributedString(string: "Not really",
                                            attributes: [.foregroundColor: UIColor.white])
            return LPRatingViewConfiguration(title: title,
                                             approvalButtonTitle: title2,
                                             rejectionButtonTitle: title3)
            
        case .approval:
            let title = NSAttributedString(string: "How about rating, then?",
                                           attributes: [.foregroundColor: UIColor.white])
            let title2 = NSAttributedString(string: "Ok, sure",
                                            attributes: [.foregroundColor: UIColor(red: 0.376, green: 0.788, blue: 0.773, alpha: 1.00)])
            let title3 = NSAttributedString(string: "No, thanks",
                                            attributes: [.foregroundColor: UIColor.white])
            return LPRatingViewConfiguration(title: title,
                                             approvalButtonTitle: title2,
                                             rejectionButtonTitle: title3)
        case .rejection:
            let title = NSAttributedString(string: "Would you mind giving us some feedback",
                                           attributes: [.foregroundColor: UIColor.white])
            let title2 = NSAttributedString(string: "Ok, sure",
                                            attributes: [.foregroundColor: UIColor(red: 0.376, green: 0.788, blue: 0.773, alpha: 1.00)])
            let title3 = NSAttributedString(string: "No, thanks",
                                            attributes: [.foregroundColor: UIColor.white])
            return LPRatingViewConfiguration(title: title,
                                             approvalButtonTitle: title2,
                                             rejectionButtonTitle: title3)
        }
    }
}

```



### UITableView

Simply create an instance of `LPRatingTableViewCell`, assign the delegate and return it!

```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	let cell = LPRatingTableViewCell(style: .default, reuseIdentifier: nil)
	cell.delegate = self
        
	return cell
}
```

### UICollectionView

First register the class

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Register class
    collectionView?.register(LPRatingCollectionViewCell.self, forCellWithReuseIdentifier: "testCell")
}
```
Then simply create an instance of `LPRatingCollectionViewCell`, assign the delegate and return it

```swift
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath) as! LPRatingCollectionViewCell
    cell.delegate = self
    
    return cell
}
```

## View Flow

Here is the flow of the view, and the types of cases that will be passed to the delegate along the way.

![doc-flow](https://raw.githubusercontent.com/luispadron/LPIntegratedRating/master/.github/DocumentationFlow.png)

## Documentation

Read the full documentation [here](https://htmlpreview.github.io/?https://raw.githubusercontent.com/luispadron/LPIntegratedRating/master/docs/index.html)



