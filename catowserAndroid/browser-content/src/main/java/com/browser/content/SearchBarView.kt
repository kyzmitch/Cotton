package com.browser.content

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import com.browser.content.ui.theme.Purple200
import com.browser.content.ui.theme.Purple700
import com.cotton.browser.R

/*
* - Uses experimental api only for `LocalSoftwareKeyboardController`
* - whole code is a modified version from
*   https://www.devbitsandbytes.com/configuring-searchview-in-jetpack-compose/
* */

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun SearchBarView(
    searchText: String,
    placeholderText: String,
    onSearchTextChanged: (String) -> Unit = {},
    onClearClick: () -> Unit = {}
) {
    var showClearButton by remember { mutableStateOf(false) }
    val keyboardController = LocalSoftwareKeyboardController.current
    val focusRequester = remember { FocusRequester() }

    OutlinedTextField(
        modifier = Modifier
            .fillMaxSize()
            .padding(vertical = 0.dp)
            .onFocusChanged { focusState ->
                showClearButton = (focusState.isFocused)
            }
            .focusRequester(focusRequester),
        value = searchText,
        onValueChange = onSearchTextChanged,
        placeholder = {
            Text(
                text = placeholderText,
                color = Purple700
            ) // Placeholder
        },
        colors = TextFieldDefaults.textFieldColors(
            focusedIndicatorColor = Purple200,
            unfocusedIndicatorColor = Purple200,
            backgroundColor = Purple200,
            cursorColor = LocalContentColor.current.copy(alpha = LocalContentAlpha.current)
        ),
        leadingIcon = {
            Icon(
                imageVector = Icons.Filled.Search,
                modifier = Modifier,
                contentDescription = stringResource(id = R.string.icn_search_magnifier_icon_description)
            ) // Search magnifier icon in SearchBar
        },
        trailingIcon = {
            AnimatedVisibility(
                visible = showClearButton,
                enter = fadeIn(),
                exit = fadeOut()
            ) {
                IconButton(onClick = {
                    keyboardController?.hide()
                    onClearClick()
                }) {
                    Icon(
                        imageVector = Icons.Filled.Close,
                        contentDescription = stringResource(id = R.string.icn_search_clear_content_description)
                    )
                } // Cancel button for SearchBar
            }
        },
        maxLines = 1,
        singleLine = true,
        keyboardOptions = KeyboardOptions.Default.copy(imeAction = ImeAction.Done),
        keyboardActions = KeyboardActions(onDone = {
            keyboardController?.hide()
        }),
    ) // OutlinedTextField
}