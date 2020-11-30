CREATE TABLE [dbo].[CO_AreaContractualYacimiento] (
    [IdACYacimiento]    INT IDENTITY (1, 1) NOT NULL,
    [IdAreaContractual] INT NULL,
    [IdYacimiento]      INT NULL,
    [CreadoPor]         INT NULL,
    CONSTRAINT [PK_AreaContractualYacimientos] PRIMARY KEY CLUSTERED ([IdACYacimiento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

