export type Recipes = Recipe[]

export interface Recipe {
    name: Legend,
    brewer: string
    grind: string
    coffee: number
    water_ml: number
    water_temp: number
    total_time: number[]
    before_event?: BeforeEvent
    events: Event[]
}

export interface BeforeEvent {
    event_type: string
    name: Legend
}

export interface Event {
    event_type: string
    time: number
    name: Legend
    name_note?: string
    quantity?: Quantity
    duration?: number
    range?: number
    note?: string
}

export interface Quantity {
    value: number
    tare: boolean
}

enum Legend {
    Bloom,
    Break_crust,
    Cap_on,
    Distribute,
    Draw_down,
    Grind,
    Invert,
    Pour,
    Press,
    Swirl,
    Stop_brew,
    Stir,
}

