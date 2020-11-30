CREATE TABLE [dbo].[EN_Entidad] (
    [IdEntidad]     INT            IDENTITY (1, 1) NOT NULL,
    [Entidad]       NVARCHAR (MAX) NULL,
    [NombreEntidad] NVARCHAR (MAX) NULL,
    [CreadoPor]     INT            NULL,
    CONSTRAINT [PK_Cat_General_Entidades] PRIMARY KEY CLUSTERED ([IdEntidad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

