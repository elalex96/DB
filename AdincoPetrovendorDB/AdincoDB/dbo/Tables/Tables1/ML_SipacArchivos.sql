CREATE TABLE [dbo].[ML_SipacArchivos] (
    [IdSipacArchivos]   INT            IDENTITY (10000, 1) NOT NULL,
    [SipacMailId]       INT            NULL,
    [Contratista]       NVARCHAR (250) NULL,
    [IDRegFiducidiario] NVARCHAR (250) NULL,
    [Periodo]           DATE           NULL,
    [NombreArchivo]     NVARCHAR (250) NULL,
    [HashSHA256]        NVARCHAR (500) NULL,
    [FechaCarga]        DATETIME       NULL,
    CONSTRAINT [PK_SipacArchivos] PRIMARY KEY CLUSTERED ([IdSipacArchivos] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

