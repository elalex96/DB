CREATE TABLE [dbo].[CO_IDPadreCIEP] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [ID_CATACTIV]    FLOAT (53)     NULL,
    [ID_CATSUBACTIV] FLOAT (53)     NULL,
    [ID_TIPOSER]     FLOAT (53)     NULL,
    [AC_PRESUP_MES]  FLOAT (53)     NULL,
    [AC_NOMBRE]      NVARCHAR (255) NULL,
    [AC_DESCRIPCION] NVARCHAR (255) NULL,
    [AC_FEC_INI]     DATETIME       NULL,
    [AC_FEC_FIN]     DATETIME       NULL,
    [AC_TERMINADO]   NVARCHAR (255) NULL,
    [ID_ADMON]       FLOAT (53)     NULL,
    [ID_CATACTHC]    FLOAT (53)     NULL,
    [ID_ACTIVIDAD]   FLOAT (53)     NULL,
    [IdPresupuesto]  INT            NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_IDPadre] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IDPadre_Presupuestos] FOREIGN KEY ([IdPresupuesto]) REFERENCES [dbo].[CO_Presupuesto] ([IdPresupuesto])
);

