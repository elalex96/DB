CREATE TABLE [dbo].[MPY_RegistroWS] (
    [IdRegistroWS] INT           IDENTITY (1, 1) NOT NULL,
    [RFC]          NVARCHAR (50) NULL,
    [Fecha]        DATETIME      NULL,
    CONSTRAINT [PK_MPY_RegistroWS] PRIMARY KEY CLUSTERED ([IdRegistroWS] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

