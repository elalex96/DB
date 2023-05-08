CREATE TABLE [dbo].[AM_OneSignalPlayers] (
    [IdDevice]     INT            IDENTITY (1, 1) NOT NULL,
    [PlayerId]     NVARCHAR (200) NULL,
    [Usuario]      NVARCHAR (200) NULL,
    [CreadoEl]     DATETIME       NULL,
    [ModificadoEl] DATETIME       NULL,
    [IsActivo]     BIT            NULL,
    [Dispositivo]  VARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdDevice] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

