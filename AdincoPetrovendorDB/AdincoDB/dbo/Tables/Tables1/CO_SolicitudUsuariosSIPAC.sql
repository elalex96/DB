CREATE TABLE [dbo].[CO_SolicitudUsuariosSIPAC] (
    [IdSolicitudUsuariosSIPAC] INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]               INT            NULL,
    [IdContrComerAsigFMP]      NVARCHAR (MAX) NULL,
    [IdUsuarioSIPAC]           NVARCHAR (MAX) NULL,
    [Nombre]                   VARCHAR (MAX)  NULL,
    [Apellido]                 VARCHAR (MAX)  NULL,
    [Correo]                   NVARCHAR (MAX) NULL,
    [IdPerfilAsignado]         INT            NULL,
    [RFC]                      NVARCHAR (MAX) NULL,
    [IdAccion]                 INT            NULL,
    [IdFacultado]              BIT            NULL,
    [CreadoPor]                INT            NULL,
    [CreadoEn]                 DATE           NULL,
    [ModificadoPor]            INT            NULL,
    [ModificadoEn]             DATE           NULL
);

