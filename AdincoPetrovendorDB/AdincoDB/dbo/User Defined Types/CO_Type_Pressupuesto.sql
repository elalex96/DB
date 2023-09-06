CREATE TYPE CO_Type_Pressupuesto AS TABLE
(
    IdPresupuesto INT NULL,
    Nombre VARCHAR(500) NULL,
    IdPresupuestoCNH VARCHAR(500) NULL,
    Actual BIT NULL,
    ActivoProcura BIT NULL,
    InicioPresupuesto DATE NULL,
    FinPresupuesto DATE NULL,
    IdContratoSeleccionado INT NULL
);