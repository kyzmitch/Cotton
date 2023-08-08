package org.cotton.browser.content

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.Icon
import androidx.compose.material.IconButton
import androidx.compose.material.LocalContentAlpha
import androidx.compose.material.LocalContentColor
import androidx.compose.material.OutlinedTextField
import androidx.compose.material.Text
import androidx.compose.material.TextFieldDefaults
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import org.cotton.browser.content.ui.theme.Purple200
import org.cotton.browser.content.ui.theme.Purple700
import org.cotton.browser.content.viewmodel.SearchBarViewModel

/*
* - Uses experimental api only for `LocalSoftwareKeyboardController`
* - whole code is a modified version from
*   https://www.devbitsandbytes.com/configuring-searchview-in-jetpack-compose/
* */

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun SearchBarView(viewModel: SearchBarViewModel) {
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
        value = viewModel.searchText,
        onValueChange = viewModel.onSearchTextChanged,
        placeholder = {
            Text(
                text = viewModel.placeholderText,
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
                    viewModel.onClearClick()
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
        })
    ) // OutlinedTextField
}
