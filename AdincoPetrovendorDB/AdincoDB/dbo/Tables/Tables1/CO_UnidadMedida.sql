CREATE TABLE [dbo].[CO_UnidadMedida] (
    [idUnidadMedida] INT            IDENTITY (1000, 1) NOT NULL,
    [Nombre]         NVARCHAR (MAX) NULL,
    [Abreviatura]    NVARCHAR (MAX) NULL,
    [idTipoBase]     INT            NULL,
    PRIMARY KEY CLUSTERED ([idUnidadMedida] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([idTipoBase]) REFERENCES [dbo].[CO_TipoBasesNominacion] ([idTipoBase]),
    CONSTRAINT [FK__CO_Unidad__idTip__00CC74E3] FOREIGN KEY ([idTipoBase]) REFERENCES [dbo].[CO_TipoBasesNominacion] ([idTipoBase])
);

