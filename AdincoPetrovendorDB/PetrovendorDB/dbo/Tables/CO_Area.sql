CREATE TABLE [dbo].[CO_Area] (
    [IdArea]        INT            IDENTITY (1, 1) NOT NULL,
    [NombreArea]    NVARCHAR (MAX) NULL,
    [IdResponsable] INT            NULL,
    [IdUsuario]     INT            NULL,
    [FecMovto]      DATETIME       NULL,
    [IdProveedor]   INT            NULL,
    [CreadoPor]     INT            NULL,
    CONSTRAINT [PK_Areas] PRIMARY KEY CLUSTERED ([IdArea] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

