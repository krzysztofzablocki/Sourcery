import DZNWebViewController

let modalHeight: CGFloat = 660

class WebViewController: DZNWebViewController {
    var showToolbar = true

    convenience override init(url: URL) {
        self.init()
        self.url = url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = view as! UIWebView
        webView.scalesPageToFit = true

        self.navigationItem.rightBarButtonItem = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated:false)
        navigationController?.setToolbarHidden(!showToolbar, animated:false)
    }
}

class ModalWebViewController: WebViewController {
    var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton = UIButton()
        view.addSubview(closeButton)
        closeButton.titleLabel?.font = UIFont.sansSerifFont(withSize: 14)
        closeButton.setTitleColor(.artsyGrayMedium(), for:.normal)
        closeButton.setTitle("CLOSE", for:.normal)
        closeButton.constrainWidth("140", height: "72")
        closeButton.alignTop("0", leading:"0", bottom:nil, trailing:nil, to:view)
        closeButton.addTarget(self, action:#selector(closeTapped(_:)), for:.touchUpInside)

        var height = modalHeight
        if let nav = navigationController {
            if !nav.isNavigationBarHidden { height -= nav.navigationBar.frame.height }
            if !nav.isToolbarHidden { height -= nav.toolbar.frame.height }
        }
        preferredContentSize = CGSize(width: 815, height: height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.view.superview?.layer.cornerRadius = 0
    }

    func closeTapped(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion:nil)
    }
}
