/**
 * Karabiner Config Builder
 *
 * Taken from @wincent https://github.com/wincent/wincent
 *
 * node karabiner.mjs --emit-karabiner-config > ~/.config/karabiner/karabiner.json
 * launchctl stop org.pqrs.karabiner.karabiner_console_user_server
 * launchctl start org.pqrs.karabiner.karabiner_console_user_server
 */

function fromTo(from, to) {
    return [
        {
            from: {
                key_code: from,
            },
            to: {
                key_code: to,
            },
        },
    ];
}

export function bundleIdentifier(identifier) {
    return '^' + identifier.replace(/\./g, '\\.') + '$';
}

/**
 * For a given Colemak key (ie. the key I "think" I'm pressing), return
 * the corresponding Qwerty key on the physical keyboard (ie. the key
 * Karabiner-Elements needs to manipulate).
 */
function colemak(key) {
    return (
        {
            d: 'g',
            e: 'k',
            f: 'e',
            g: 't',
            i: 'l',
            j: 'y',
            k: 'n',
            l: 'u',
            n: 'j',
            o: 'semicolon',
            p: 'r',
            r: 's',
            s: 'd',
            semicolon: 'p',
            t: 'f',
            u: 'i',
            y: 'o',
        }[key] || key
    );
}

function launch(from, ...args) {
    return [
        {
            from: {
                simultaneous: [
                    {
                        key_code: colemak('o'), // mnemonic: "[o]pen")
                    },
                    {
                        key_code: from,
                    },
                ],
                simultaneous_options: {
                    key_down_order: 'strict',
                    key_up_order: 'strict_inverse',
                },
            },
            parameters: {
                'basic.simultaneous_threshold_milliseconds': 100 /* Default: 1000 */,
            },
            to: [
                {
                    shell_command: ['open', ...args].join(' '),
                },
            ],
            type: 'basic',
        },
    ];
}

function spaceFN(from, to) {
    return [
        {
            from: {
                modifiers: {
                    optional: ['any'],
                },
                simultaneous: [
                    {
                        key_code: 'spacebar',
                    },
                    {
                        key_code: from,
                    },
                ],
                simultaneous_options: {
                    key_down_order: 'strict',
                    key_up_order: 'strict_inverse',
                    to_after_key_up: [
                        {
                            set_variable: {
                                name: 'SpaceFN',
                                value: 0,
                            },
                        },
                    ],
                },
            },
            parameters: {
                'basic.simultaneous_threshold_milliseconds': 500 /* Default: 1000 */,
            },
            to: [
                {
                    set_variable: {
                        name: 'SpaceFN',
                        value: 1,
                    },
                },
                {
                    key_code: to,
                },
            ],
            type: 'basic',
        },
        {
            conditions: [
                {
                    name: 'SpaceFN',
                    type: 'variable_if',
                    value: 1,
                },
            ],
            from: {
                key_code: from,
                modifiers: {
                    optional: ['any'],
                },
            },
            to: [
                {
                    key_code: to,
                },
            ],
            type: 'basic',
        },
    ];
}

function swap(a, b) {
    return [...fromTo(a, b), ...fromTo(b, a)];
}

const DEVICE_DEFAULTS = {
    disable_built_in_keyboard_if_exists: false,
    fn_function_keys: [],
    ignore: false,
    manipulate_caps_lock_led: true,
    simple_modifications: [],
};

const IDENTIFIER_DEFAULTS = {
    is_keyboard: true,
    is_pointing_device: false,
};

const APPLE_INTERNAL_US = {
    ...DEVICE_DEFAULTS,
    identifiers: {
        ...IDENTIFIER_DEFAULTS,
        product_id: 628,
        vendor_id: 1452,
    },
};

const APPLE_INTERNAL_ES = {
    ...DEVICE_DEFAULTS,
    identifiers: {
        ...IDENTIFIER_DEFAULTS,
        product_id: 636,
        vendor_id: 1452,
    },
    simple_modifications: [
        ...fromTo('non_us_backslash', 'grave_accent_and_tilde'),
        ...fromTo('grave_accent_and_tilde', 'left_shift'),
        ...fromTo('backslash', 'return_or_enter'),
    ],
};

const APPLE_MAGIC_W_NUM_US = {
    ...DEVICE_DEFAULTS,
    identifiers: {
        ...IDENTIFIER_DEFAULTS,
        product_id: 620,
        vendor_id: 76,
    },
};

const REALFORCE = {
    ...DEVICE_DEFAULTS,
    identifiers: {
        ...IDENTIFIER_DEFAULTS,
        product_id: 273,
        vendor_id: 2131,
    },
    simple_modifications: [
        ...swap('left_command', 'left_option'),
        ...swap('right_command', 'right_option'),
        ...fromTo('application', 'fn'),
        ...fromTo('pause', 'power'),
    ],
};

const PARAMETER_DEFAULTS = {
    'basic.simultaneous_threshold_milliseconds': 50,
    'basic.to_delayed_action_delay_milliseconds': 500,
    'basic.to_if_alone_timeout_milliseconds': 200 /* Default: 1000 */,
    'basic.to_if_held_down_threshold_milliseconds': 500,
};

const VANILLA_PROFILE = {
    complex_modifications: {
        parameters: PARAMETER_DEFAULTS,
        rules: [],
    },
    devices: [],
    fn_function_keys: [
        ...fromTo('f1', 'display_brightness_decrement'),
        ...fromTo('f2', 'display_brightness_increment'),
        ...fromTo('f3', 'mission_control'),
        ...fromTo('f4', 'launchpad'),
        ...fromTo('f5', 'illumination_decrement'),
        ...fromTo('f6', 'illumination_increment'),
        ...fromTo('f7', 'rewind'),
        ...fromTo('f8', 'play_or_pause'),
        ...fromTo('f9', 'fastforward'),
        ...fromTo('f10', 'mute'),
        ...fromTo('f11', 'volume_decrement'),
        ...fromTo('f12', 'volume_increment'),
    ],
    name: 'Vanilla',
    selected: false,
    simple_modifications: [],
    virtual_hid_keyboard: {
        caps_lock_delay_milliseconds: 0,
        keyboard_type: 'ansi',
    },
};

export function isObject(item) {
    return (
        item !== null &&
        Object.prototype.toString.call(item) === '[object Object]'
    );
}

export function deepCopy(item) {
    if (Array.isArray(item)) {
        return item.map(deepCopy);
    } else if (isObject(item)) {
        const copy = {};
        Object.entries(item).forEach(([k, v]) => {
            copy[k] = deepCopy(v);
        });
        return copy;
    }
    return item;
}

/**
 * Visit the data structure, `item`, navigating to `path` and passing the
 * value(s) at that location into the `updater` function, which may return a
 * substitute value or the original item (if no changes are made, the original
 * item is returned).
 *
 * `path` is a tiny JSONPath subset, and may contain:
 *
 * - `$`: selects the root object.
 * - `.child`: selects a child property.
 * - `[start:end]`: selects an array slice; `end` is optional.
 */
export function visit(item, path, updater) {
    const match = path.match(
        /^(?<root>\$)|\.(?<child>\w+)|\[(?<slice>.+?)\]|(?<done>$)/
    );
    const {
        groups: {root, child, slice},
    } = match;
    const subpath = path.slice(match[0].length);
    if (root) {
        return visit(item, subpath, updater);
    } else if (child) {
        const next = visit(item[child], subpath, updater);
        if (next !== undefined) {
            return {
                ...item,
                [child]: next,
            };
        }
    } else if (slice) {
        const {
            groups: {start, end},
        } = slice.match(/^(?<start>\d+):(?<end>\d+)?$/);
        let array;
        for (
            let i = start, max = end == null ? item.length : end;
            i < max;
            i++
        ) {
            const next = visit(item[i], subpath, updater);
            if (next !== undefined) {
                if (!array) {
                    array = item.slice(0, i);
                }
                array[i] = next;
            } else if (array) {
                array[i] = item[i];
            }
        }
        return array;
    } else {
        const next = updater(item);
        return next === item ? undefined : next;
    }
}

const EXEMPTIONS = ['com.factorio', 'com.feralinteractive.dirtrally'];

function applyExemptions(profile) {
    const exemptions = {
        type: 'frontmost_application_unless',
        bundle_identifiers: EXEMPTIONS.map(bundleIdentifier),
    };

    return visit(
        profile,
        '$.complex_modifications.rules[0:].manipulators[0:].conditions',
        (conditions) => {
            if (conditions) {
                if (
                    conditions.some(
                        (condition) =>
                            condition.type === 'frontmost_application_if'
                    )
                ) {
                    return conditions;
                }
                return [...deepCopy(conditions), exemptions];
            } else {
                return [exemptions];
            }
        }
    );
}

const DEFAULT_PROFILE = applyExemptions({
    ...VANILLA_PROFILE,
    complex_modifications: {
        parameters: {
            ...PARAMETER_DEFAULTS,
            'basic.to_if_alone_timeout_milliseconds': 500 /* Default: 1000 */,
        },
        rules: [
            {
                description: 'Caps Lock and Return together mouse middle click',
                manipulators: [
                    {
                        from: {
                            modifiers: {
                                optional: ['any'],
                            },
                            simultaneous: [
                                {
                                    key_code: 'caps_lock',
                                },
                                {
                                    key_code: 'return_or_enter',
                                },
                            ],
                            simultaneous_options: {
                                key_down_order: 'insensitive',
                                key_up_order: 'insensitive',
                            },
                        },
                        to: [
                            {
                                pointing_button: 'button3',
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            // {
            //     description: 'Launcher',
            //     manipulators: [
            //         ...launch(
            //             colemak('b' /* [b]rowser */),
            //             '-b',
            //             'com.google.Chrome'
            //         ),
            //         ...launch(
            //             colemak('c' /* [c]alendar */),
            //             '-b',
            //             'com.flexibits.fantastical2.mac'
            //         ),
            //         ...launch(
            //             colemak('d' /* [d]ownloads */),
            //             '-b',
            //             'com.apple.Finder',
            //             '~/Downloads'
            //         ),
            //         ...launch(
            //             colemak('f' /* [F]inder */),
            //             '-b',
            //             'com.apple.Finder'
            //         ),
            //         ...launch(
            //             colemak('p' /* [p]asswords */),
            //             '-b',
            //             'com.lastpass.LastPass'
            //         ),
            //         ...launch(
            //             colemak('s' /* [S]lack */),
            //             '-b',
            //             'com.tinyspeck.slackmacgap'
            //         ),
            //         ...launch(
            //             colemak('t' /* [t]erminal */),
            //             '-b',
            //             'io.alacritty'
            //         ),
            //     ],
            // },
            {
                description: 'SpaceFN layer',
                manipulators: [
                    ...spaceFN('b', 'spacebar'),
                    ...spaceFN('f', 'right_arrow'),
                    ...spaceFN('d', 'down_arrow'),
                    ...spaceFN('s', 'left_arrow'),
                    ...spaceFN('e', 'up_arrow'),

                    ...spaceFN('l', 'right_arrow'),
                    ...spaceFN('k', 'down_arrow'),
                    ...spaceFN('j', 'left_arrow'),
                    ...spaceFN('i', 'up_arrow'),

                    ...spaceFN('u', 'right_arrow'),
                    ...spaceFN('y', 'down_arrow'),
                    ...spaceFN('h', 'left_arrow'),
                    ...spaceFN('n', 'up_arrow'),
                ],
            },
            // {
            //     description: 'SpaceFN layer',
            //     manipulators: [
            //         ...spaceFN('m', '1'),
            //         ...spaceFN('comma', '2'),
            //         ...spaceFN('period', '3'),
            //         ...spaceFN('j', '4'),
            //         ...spaceFN('k', '5'),
            //         ...spaceFN('l', '6'),
            //         ...spaceFN('u', '7'),
            //         ...spaceFN('i', '8'),
            //         ...spaceFN('o', '9'),
            //         ...spaceFN('n', '0'),
            //         ...spaceFN('slash', 'period'),
            //         ...spaceFN('b', 'spacebar'),
            //         ...spaceFN('f', 'right_arrow'),
            //         ...spaceFN('d', 'down_arrow'),
            //         ...spaceFN('s', 'left_arrow'),
            //         ...spaceFN('e', 'up_arrow'),
            //     ],
            // },
            // {
            //     description: 'SpaceFN layer',
            //     manipulators: [
            //         ...spaceFN('x', '1'),
            //         ...spaceFN('c', '2'),
            //         ...spaceFN('v', '3'),
            //         ...spaceFN('s', '4'),
            //         ...spaceFN('d', '5'),
            //         ...spaceFN('f', '6'),
            //         ...spaceFN('w', '7'),
            //         ...spaceFN('e', '8'),
            //         ...spaceFN('r', '9'),
            //         ...spaceFN('z', '0'),
            //         ...spaceFN('b', 'spacebar'),
            //         ...spaceFN('u', 'right_arrow'),
            //         ...spaceFN('y', 'down_arrow'),
            //         ...spaceFN('h', 'left_arrow'),
            //         ...spaceFN('n', 'up_arrow'),
            //         ...spaceFN('l', 'right_arrow'),
            //         ...spaceFN('k', 'down_arrow'),
            //         ...spaceFN('j', 'left_arrow'),
            //         ...spaceFN('i', 'up_arrow'),
            //     ],
            // },
            {
                description: 'Tab + Return to Backslash on ES Apple board',
                manipulators: [
                    {
                        from: {
                            modifiers: {
                                optional: ['any'],
                            },
                            simultaneous: [
                                {
                                    key_code: 'tab',
                                },
                                {
                                    key_code: 'return_or_enter',
                                },
                            ],
                            simultaneous_options: {
                                key_down_order: 'insensitive',
                                key_up_order: 'insensitive',
                            },
                        },
                        to: [
                            {
                                key_code: 'backslash',
                            },
                        ],
                        conditions: [
                            {
                                type: 'device_if',
                                identifiers: [APPLE_INTERNAL_ES.identifiers],
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            {
                description:
                    'Disable Karabiner-Elements with Fn+Control+Option+Command+Z',
                manipulators: [
                    {
                        type: 'basic',
                        from: {
                            key_code: 'z',
                            modifiers: {
                                mandatory: [
                                    'fn',
                                    'left_control',
                                    'left_command',
                                    'left_option',
                                ],
                            },
                        },
                        to: [
                            {
                                shell_command:
                                    'osascript ~/bin/karabiner-kill.applescript',
                            },
                        ],
                    },
                ],
            },
            {
                description:
                    'Change Caps Lock to Control when used as modifier, Escape when used alone',
                manipulators: [
                    {
                        from: {
                            key_code: 'caps_lock',
                            modifiers: {
                                optional: ['any'],
                            },
                        },
                        to: [
                            {
                                key_code: 'left_control',
                            },
                        ],
                        to_if_alone: [
                            {
                                key_code: 'escape',
                            },
                        ],
                        to_if_held_down: [
                            {
                                key_code: 'left_control',
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            {
                description: 'Change Return to Control when used as modifier, Return when used alone',
                manipulators: [
                    {
                        from: {
                            key_code: 'return_or_enter',
                            modifiers: {
                                optional: ['any'],
                            },
                        },
                        to: [
                            {
                                key_code: 'right_control',
                                lazy: true,
                            },
                        ],
                        to_if_alone: [
                            {
                                key_code: 'return_or_enter',
                            },
                        ],
                        to_if_held_down: [
                            {
                                key_code: 'return_or_enter',
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            {
                description: 'Change Control+I to F6 in Vim',
                manipulators: [
                    {
                        conditions: [
                            {
                                bundle_identifiers: [
                                    bundleIdentifier('com.apple.Terminal'),
                                    bundleIdentifier('io.alacritty'),
                                    bundleIdentifier('com.googlecode.iterm2'),
                                    bundleIdentifier('org.vim.MacVim.plist'),
                                ],
                                type: 'frontmost_application_if',
                            },
                        ],
                        from: {
                            key_code: 'l',
                            modifiers: {
                                mandatory: ['control'],
                                optional: ['any'],
                            },
                        },
                        to: [
                            {
                                key_code: 'f6',
                                modifiers: ['fn'],
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            {
                description: 'Left and Right Shift together toggle Caps Lock',
                manipulators: [
                    {
                        from: {
                            modifiers: {
                                optional: ['any'],
                            },
                            simultaneous: [
                                {
                                    key_code: 'left_shift',
                                },
                                {
                                    key_code: 'right_shift',
                                },
                            ],
                            simultaneous_options: {
                                key_down_order: 'insensitive',
                                key_up_order: 'insensitive',
                            },
                        },
                        to: [
                            {
                                key_code: 'caps_lock',
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            {
                description:
                    'Change Left Shift to Left Shift when used as modifier, ( when used alone',
                manipulators: [
                    {
                        from: {
                            key_code: 'left_shift',
                            modifiers: {
                                optional: ['any'],
                            },
                        },
                        to: [
                            {
                                key_code: 'left_shift',
                            },
                        ],
                        to_if_alone: [
                            {
                                key_code: '9',
                                modifiers: 'left_shift',
                            },
                        ],
                        to_if_held_down: [
                            {
                                key_code: 'left_shift',
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
            {
                description:
                    'Change Right Shift to Right Shift when used as modifier, ( when used alone',
                manipulators: [
                    {
                        from: {
                            key_code: 'right_shift',
                            modifiers: {
                                optional: ['any'],
                            },
                        },
                        to: [
                            {
                                key_code: 'right_shift',
                            },
                        ],
                        to_if_alone: [
                            {
                                key_code: '0',
                                modifiers: 'right_shift',
                            },
                        ],
                        to_if_held_down: [
                            {
                                key_code: 'right_shift',
                            },
                        ],
                        type: 'basic',
                    },
                ],
            },
        ],
    },
    devices: [REALFORCE, APPLE_INTERNAL_US, APPLE_INTERNAL_ES, APPLE_MAGIC_W_NUM_US],
    name: 'Default',
    selected: true,
});

const CONFIG = {
    global: {
        check_for_updates_on_startup: true,
        show_in_menu_bar: true,
        show_profile_name_in_menu_bar: false,
    },
    profiles: [DEFAULT_PROFILE, VANILLA_PROFILE],
};

if (process.argv.includes('--emit-karabiner-config')) {
    process.stdout.write(JSON.stringify(CONFIG, null, 2) + '\n');
}
