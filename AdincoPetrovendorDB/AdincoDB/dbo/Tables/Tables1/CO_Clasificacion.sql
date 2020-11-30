CREATE TABLE [dbo].[CO_Clasificacion] (
    [IdClasificacion]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreClasificacion] NVARCHAR (MAX) NULL,
    [CreadoPor]           INT            NULL,
    CONSTRAINT [PK_Clasificacion] PRIMARY KEY CLUSTERED ([IdClasificacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

