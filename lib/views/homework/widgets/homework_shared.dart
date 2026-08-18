part of 'homework_widget.dart';

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _onlineClassAccentSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE2E7)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: _onlineClassAccent, size: 38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.mediumPrimaryBold.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: AppTextStyle.normalPrimaryRegular.copyWith(
                    color: _homeworkMutedText,
                    height: 1.25,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.value,
    required this.label,
    this.icon,
    this.accentColor = _onlineClassAccent,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _onlineClassAccentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _onlineClassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 25),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  icon == null
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyle.mediumPrimaryBold.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyle.smallPrimaryRegular,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    this.isPrimary = false,
    this.isSelected = false,
    this.onTap,
  });

  final _DashboardAction action;
  final bool isPrimary;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isFilled = isPrimary && isSelected;

    return Material(
      color: isFilled ? _onlineClassAccent : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isPrimary ? 14 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _onlineClassAccent : _onlineClassBorder,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child:
              isPrimary
                  ? _primaryContent(isFilled: isFilled)
                  : _compactContent(),
        ),
      ),
    );
  }

  Widget _primaryContent({required bool isFilled}) {
    return Row(
      children: [
        _IconBox(
          icon: action.icon,
          backgroundColor:
              isFilled
                  ? Colors.white.withOpacity(0.14)
                  : _onlineClassAccentSoft,
          iconColor: isFilled ? Colors.white : _onlineClassAccent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.titleKey.tr,
                style:
                    isFilled
                        ? AppTextStyle.mediumWhiteSemiBold
                        : AppTextStyle.mediumPrimaryBold.copyWith(
                          color: _onlineClassAccent,
                        ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitleKey.tr,
                style:
                    isFilled
                        ? AppTextStyle.normalWhiteRegular
                        : AppTextStyle.smallGreyRegular,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: isFilled ? Colors.white : AppColor.darkGrey,
        ),
      ],
    );
  }

  Widget _compactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? _onlineClassAccent : action.iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            action.icon,
            color: isSelected ? Colors.white : action.iconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          action.titleKey.tr,
          style: AppTextStyle.normalPrimaryBold.copyWith(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          action.subtitleKey.tr,
          style: AppTextStyle.smallGreyRegular.copyWith(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _WideActionTile extends StatelessWidget {
  const _WideActionTile({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _onlineClassAccentLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _onlineClassBorder),
            ),
            child: Row(
              children: [
                _IconBox(icon: action.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.titleKey.tr,
                        style: AppTextStyle.normalPrimaryBold,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        action.subtitleKey.tr,
                        style: AppTextStyle.smallGreyRegular,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColor.darkGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.children,
    this.showTitle = true,
  });

  final String title;
  final List<Widget> children;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _onlineClassAccentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _onlineClassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              title,
              style: AppTextStyle.mediumPrimaryBold.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _onlineClassAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.normalPrimarySemiBold),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyle.smallGreyRegular,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColor.darkGrey),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    this.backgroundColor = _onlineClassAccentSoft,
    this.iconColor = _onlineClassAccent,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 23),
    );
  }
}

class _DashboardAction {
  const _DashboardAction(
    this.icon,
    this.titleKey,
    this.subtitleKey, {
    this.iconColor = _onlineClassAccent,
  });

  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color iconColor;
}
