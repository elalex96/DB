CREATE TABLE [dbo].[AP_Tableros] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [IdContrato]     INT           NULL,
    [Workbook]       VARCHAR (300) NULL,
    [Sheet]          VARCHAR (300) NULL,
    [Tabs]           VARCHAR (300) NULL,
    [Site]           VARCHAR (300) NULL,
    [DNS]            VARCHAR (300) NULL,
    [CreadoPor]      INT           NULL,
    [CreadoEn]       DATETIME      NULL,
    [ModificadoPor]  INT           NULL,
    [ModificadoEn]   DATETIME      NULL,
    [Activo]         BIT           NULL,
    [HeightPX]       INT           NULL,
    [IdRol]          INT           NULL,
    [NombreMostrar]  VARCHAR (300) NULL,
    [Parametros]     VARCHAR (300) NULL,
    [UserTableau]    VARCHAR (300) NULL,
    [MuestraToolbar] BIT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

