CREATE TABLE [dbo].[PV_Nacionalidad] (
    [NacionalidadID] INT          IDENTITY (1, 1) NOT NULL,
    [Nacionalidad]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Cat_NacionalidadEmpresa] PRIMARY KEY CLUSTERED ([NacionalidadID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

