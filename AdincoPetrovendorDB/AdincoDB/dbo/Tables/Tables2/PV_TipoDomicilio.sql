CREATE TABLE [dbo].[PV_TipoDomicilio] (
    [TipoDomicilioID] INT          NOT NULL,
    [TipoDomicilio]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TipoDomicilio] PRIMARY KEY CLUSTERED ([TipoDomicilioID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

