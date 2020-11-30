CREATE TABLE [dbo].[FI_CFDICromatografia] (
    [IdCFDICromatografia] INT            IDENTITY (1, 1) NOT NULL,
    [IdFacturaConcepto]   INT            NULL,
    [XML]                 VARCHAR (3000) NULL,
    [C6]                  VARCHAR (10)   NULL,
    [InicioC6]            INT            NULL,
    [NC5]                 VARCHAR (10)   NULL,
    [InicioNC5]           INT            NULL,
    [IC5]                 VARCHAR (10)   NULL,
    [InicioIC6]           INT            NULL,
    [NC4]                 VARCHAR (10)   NULL,
    [InicioNC4]           INT            NULL,
    [IC4]                 VARCHAR (10)   NULL,
    [InicioIC4]           INT            NULL,
    [C3]                  VARCHAR (10)   NULL,
    [InicioC3]            INT            NULL,
    [C2]                  VARCHAR (10)   NULL,
    [InicioC2]            INT            NULL,
    [C1]                  VARCHAR (10)   NULL,
    [InicioC1]            INT            NULL,
    CONSTRAINT [PK_FI_CFDICromatografia] PRIMARY KEY CLUSTERED ([IdCFDICromatografia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

