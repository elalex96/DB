CREATE TABLE [dbo].[PV_PerfilSocial] (
    [Facebook]       VARCHAR (MAX) NULL,
    [IdPerfilSocial] INT           IDENTITY (1, 1) NOT NULL,
    [IdProveedor]    INT           NOT NULL,
    [SitioWeb]       VARCHAR (MAX) NULL,
    [Twitter]        VARCHAR (MAX) NULL
);

