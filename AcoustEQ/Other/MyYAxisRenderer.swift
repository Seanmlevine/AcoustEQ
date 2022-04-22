class MyYAxisRenderer: YAxisRenderer {
    private static let titleLabelPadding: CGFloat = 20
    
    /**
     Unfortunately iOS Charts has marked many of its methods with internal visibily
     so they cannot be customized. Instead you often need to re-implement logic from
     the charting framework.
    */
    override func renderAxisLabels(context: CGContext) {
        // Render the y-labels.
        super.renderAxisLabels(context: context)
        
        // Render the y-axis title using our custom renderer.
        renderTitle(title: "Lorem ipsum dolor sit amet", inContext: context, x: MyYAxisRenderer.titleLabelPadding)
    }
}

// MARK: Y-Axis titles.
private extension MyYAxisRenderer {
    func renderTitle(title: String, inContext context: CGContext, x: CGFloat) {
        guard let yAxis = self.axis as? YAxis else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: yAxis.labelFont,
            .foregroundColor: yAxis.labelTextColor
        ]
        
        // Determine the chart title's y-position.
        let titleSize = title.size(withAttributes: attributes)
        let verticalTitleSize = CGSize(width: titleSize.height, height: titleSize.width)
        let point = CGPoint(x: x, y: (viewPortHandler.chartHeight - verticalTitleSize.height) / 2)
        
        // Render the chart title.
        ChartUtils.drawText(context: context,
                            text: title,
                            point: point,
                            attributes: attributes,
                            anchor: .zero,
                            angleRadians: .pi / -2)
    }
}
