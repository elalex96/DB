CREATE TABLE [dbo].[EN_SecuenciaCarpetas] (
    [IdCarpeta]                INT           NULL,
    [Nivel]                    INT           NULL,
    [IdCarpetaAnterior]        INT           NULL,
    [NiveAnterior]             INT           NULL,
    [Frecuencia]               INT           NULL,
    [IdContrato]               INT           NULL,
    [IsCarpetaUsuario]         BIT           NULL,
    [IsCarpetaUsuarioAnterior] BIT           NULL,
    [Ruta]                     VARCHAR (MAX) NULL,
    [RutaAnterior]             VARCHAR (MAX) NULL,
    [Activo]                   BIT           NULL,
    [IdReceptorEntregable]     INT           NULL,
    [IsPozo]                   BIT           NULL,
    [Etapa]                    INT           NULL,
    [AnioMes]                  VARCHAR (10)  NULL,
    [IdEntregable]             INT           NULL
);

