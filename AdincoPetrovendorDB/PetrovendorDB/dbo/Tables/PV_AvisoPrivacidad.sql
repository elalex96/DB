CREATE TABLE [dbo].[PV_AvisoPrivacidad] (
    [IdAvisoPrivacidad] INT           IDENTITY (1, 1) NOT NULL,
    [AvisoPrivacidad]   VARCHAR (MAX) NOT NULL,
    [FechaGuardado]     SMALLDATETIME NOT NULL, 
    [PV_AvisoPrivacidad] VARCHAR(200) NULL
);

