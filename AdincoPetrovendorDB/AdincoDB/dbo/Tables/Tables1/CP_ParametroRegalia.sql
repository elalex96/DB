CREATE TABLE [dbo].[CP_ParametroRegalia] (
    [IdParametroRegalias] INT        IDENTITY (10000, 1) NOT NULL,
    [Anio]                INT        NULL,
    [An]                  FLOAT (53) NULL,
    [Bn]                  FLOAT (53) NULL,
    [Cn]                  FLOAT (53) NULL,
    [Dn]                  FLOAT (53) NULL,
    [En]                  FLOAT (53) NULL,
    [Fn]                  FLOAT (53) NULL,
    [Gn]                  FLOAT (53) NULL,
    [Hn]                  FLOAT (53) NULL,
    CONSTRAINT [PK_CP_ParametroRegalia] PRIMARY KEY CLUSTERED ([IdParametroRegalias] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

