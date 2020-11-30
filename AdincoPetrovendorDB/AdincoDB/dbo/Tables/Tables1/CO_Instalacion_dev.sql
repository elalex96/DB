CREATE TABLE [dbo].[CO_Instalacion_dev] (
    [IdInstalacion]            INT            IDENTITY (1, 1) NOT NULL,
    [NombreInstalacion]        NVARCHAR (MAX) NULL,
    [IdInstalacionPemex]       NVARCHAR (MAX) NULL,
    [EsBolsa]                  BIT            NULL,
    [IdActividad]              INT            NULL,
    [IdUsuario]                INT            NULL,
    [FecMovto]                 DATETIME       NULL,
    [NombreInstalacionAlterno] NVARCHAR (MAX) NULL,
    [IdCatalogoSCIEP]          INT            NULL,
    [IdAreaContractual]        INT            NULL,
    [Activo]                   BIT            NULL,
    [CUIP]                     NVARCHAR (MAX) NULL,
    [WelIID]                   INT            NULL,
    [IdYacimiento]             INT            NULL,
    [IdCampo]                  INT            NULL,
    [UTMX]                     FLOAT (53)     NULL,
    [UTMY]                     FLOAT (53)     NULL,
    [CreadoPor]                INT            NULL,
    [IdEstatus]                INT            NULL
);

