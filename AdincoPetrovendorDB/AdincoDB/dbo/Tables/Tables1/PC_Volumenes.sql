CREATE TABLE [dbo].[PC_Volumenes] (
    [IdVolumen]  INT  IDENTITY (1, 1) NOT NULL,
    [IdContrato] INT  NULL,
    [Mes]        DATE NULL,
    [Petroleo]   INT  NULL,
    [Condensado] INT  NULL,
    [C1]         INT  NULL,
    [C2]         INT  NULL,
    [C3]         INT  NULL,
    [C4]         INT  NULL,
    [C5]         INT  NULL,
    CONSTRAINT [PK_PC_Volumenes] PRIMARY KEY CLUSTERED ([IdVolumen] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

