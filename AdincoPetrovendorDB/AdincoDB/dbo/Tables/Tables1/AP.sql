CREATE TABLE [dbo].[AP] (
    [APId]          INT      IDENTITY (1, 1) NOT NULL,
    [MenuId]        BIGINT   NOT NULL,
    [IdRol]         INT      NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    [Activo]        BIT      NULL,
    CONSTRAINT [PK__AP2__4C29F34F9948D27A] PRIMARY KEY CLUSTERED ([APId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__AP2__IdRol__3F9D04AD] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[AP_Rol] ([IdRol]),
    CONSTRAINT [FK__AP2__MenuId__3EA8E074] FOREIGN KEY ([MenuId]) REFERENCES [dbo].[AP_Menu] ([MenuId])
);

