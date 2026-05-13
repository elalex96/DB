CREATE TABLE [dbo].[AP_Menu] (
    [MenuId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [MenuKey]      VARCHAR (30)  NULL,
    [Link]         VARCHAR (150) NULL,
    [Texto]        VARCHAR (100) NULL,
    [Titulo]       VARCHAR (100) NULL,
    [CssClass]     VARCHAR (70)  NULL,
    [ImagenRuta]   VARCHAR (150) NULL,
    [MenuKeyPadre] VARCHAR (30)  NULL,
    [Tipo]         INT           NOT NULL,
    [Visible]      BIT           NOT NULL,
    [CreadoPor]    INT           NULL,
    PRIMARY KEY CLUSTERED ([MenuId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    UNIQUE NONCLUSTERED ([MenuKey] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

