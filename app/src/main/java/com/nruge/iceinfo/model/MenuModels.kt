package com.nruge.iceinfo.model

import kotlinx.serialization.Serializable

@Serializable
data class MenuPageResponse(
    val teaserGroups: List<MenuTeaserGroup> = emptyList(),
    val messages: List<MenuMessage> = emptyList(),
    val declarationGroup: MenuDeclarationGroup? = null
)

@Serializable
data class MenuTeaserGroup(
    val title: String = "",
    val items: List<MenuItem> = emptyList()
)

@Serializable
data class MenuItem(
    val id: Int = 0,
    val title: String = "",
    val subject: String = "",
    val picture: MenuPicture? = null,
    val priceInfo: MenuPriceInfo? = null,
    val declarationBox: MenuDeclarationBox? = null,
    val visible: Boolean = true
) {
    val imageUrl: String get() = picture?.src ?: ""
    val eurPrice: Double? get() = priceInfo?.prices?.firstOrNull { it.currency == "EUR" }?.value
    val declarationKeys: List<String>
        get() = declarationBox?.productMainGroup?.declarationGroups
            ?.flatMap { it.keys } ?: emptyList()
}

@Serializable
data class MenuPicture(val src: String = "")

@Serializable
data class MenuPriceInfo(
    val prices: List<MenuPrice> = emptyList()
)

@Serializable
data class MenuPrice(val currency: String = "", val value: Double = 0.0)

@Serializable
data class MenuDeclarationBox(
    val productMainGroup: MenuProductGroup? = null
)

@Serializable
data class MenuProductGroup(
    val declarationGroups: List<MenuItemDeclarationGroup> = emptyList()
)

@Serializable
data class MenuItemDeclarationGroup(
    val keys: List<String> = emptyList()
)

@Serializable
data class MenuDeclarationGroup(
    val items: List<MenuDeclarationEntry> = emptyList()
)

@Serializable
data class MenuDeclarationEntry(
    val key: String = "",
    val text: String = ""
)

@Serializable
data class MenuMessage(
    val type: String = "",
    val text: String = ""
)

@Serializable
data class AvailabilityItem(
    val ecmId: Int = 0,
    val status: String = "",
    val visible: Boolean = true
)

data class MenuCategory(
    val title: String,
    val items: List<MenuItem>
)

val MENU_CATEGORY_ORDER = listOf(
    "Aktion", "Snacks", "Hauptgerichte", "Frühstück", "Süß & salzig",
    "Suppe", "Kindermenü", "Vegetarisch", "Vegan", "Heißgetränke",
    "Kaltgetränke", "Alkoholische Getränke"
)
