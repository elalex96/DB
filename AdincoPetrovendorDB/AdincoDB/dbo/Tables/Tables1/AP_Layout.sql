CREATE TABLE [dbo].[AP_Layout] (
    [IdLayout]     INT             IDENTITY (10000, 1) NOT NULL,
    [Control]      NVARCHAR (MAX)  NULL,
    [NombreLayout] NVARCHAR (MAX)  NULL,
    [Layout]       VARBINARY (MAX) NULL,
    [IdUsuario]    INT             NULL,
    [Fecha]        DATETIME        NULL,
    [Compartido]   BIT             NULL,
    [PorDefecto]   BIT             NULL,
    [Activo]       BIT             NULL,
    [CreadoPor]    INT             NULL,
    CONSTRAINT [PK_Layouts] PRIMARY KEY CLUSTERED ([IdLayout] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

