CREATE TABLE [dbo].[PV_CodigoPostalRepublica] (
    [id]           INT          IDENTITY (1, 1) NOT NULL,
    [idEstado]     INT          NOT NULL,
    [estado]       VARCHAR (35) NOT NULL,
    [idMunicipio]  INT          NOT NULL,
    [municipio]    VARCHAR (60) NOT NULL,
    [ciudad]       VARCHAR (60) NULL,
    [zona]         VARCHAR (15) NOT NULL,
    [cp]           INT          NOT NULL,
    [asentamiento] VARCHAR (70) NOT NULL,
    [tipo]         VARCHAR (20) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

