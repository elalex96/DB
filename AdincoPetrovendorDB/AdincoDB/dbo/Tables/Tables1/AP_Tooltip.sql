CREATE TABLE [dbo].[AP_Tooltip] (
    [IdTooltip]   INT            IDENTITY (10000, 1) NOT NULL,
    [IdPantalla]  INT            NULL,
    [IdCampo]     INT            NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [Description] NVARCHAR (MAX) NULL,
    [Activo]      BIT            NULL,
    CONSTRAINT [PK_AP_Tooltip] PRIMARY KEY CLUSTERED ([IdTooltip] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_Tooltip_AP_Pantalla] FOREIGN KEY ([IdPantalla]) REFERENCES [dbo].[AP_Pantalla] ([IdPantalla])
);

