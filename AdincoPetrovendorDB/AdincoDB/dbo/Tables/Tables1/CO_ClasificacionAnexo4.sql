CREATE TABLE [dbo].[CO_ClasificacionAnexo4] (
    [IdAnexo4]            INT            IDENTITY (1, 1) NOT NULL,
    [ClasificacionAnexo4] NVARCHAR (MAX) NULL,
    [Clave]               NVARCHAR (MAX) NULL,
    [CreadoPor]           INT            NULL,
    CONSTRAINT [PK_ClasificacionAnexo4] PRIMARY KEY CLUSTERED ([IdAnexo4] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

