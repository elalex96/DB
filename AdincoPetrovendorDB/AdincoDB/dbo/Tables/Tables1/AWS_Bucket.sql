CREATE TABLE [dbo].[AWS_Bucket] (
    [IdBucket]      INT            IDENTITY (10000, 1) NOT NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [Acceso]        NVARCHAR (MAX) NULL,
    [Region]        NVARCHAR (MAX) NULL,
    [Descripcion]   NVARCHAR (MAX) NULL,
    [IdContrato]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    CONSTRAINT [PK_AWS_Bucket] PRIMARY KEY CLUSTERED ([IdBucket] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

